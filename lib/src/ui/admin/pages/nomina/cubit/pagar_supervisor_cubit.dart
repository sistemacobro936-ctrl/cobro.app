import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/negocio_repo.dart';
import 'package:personal/src/domain/repository/nomina_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/ui/admin/pages/nomina/nomina_util.dart';

part 'pagar_supervisor_state.dart';

/// Fila editable de la tabla de repartos
class FilaReparto {
  final int key;
  String? rutaId;
  final TextEditingController valorTxt;

  FilaReparto({required this.key, this.rutaId, String valor = ''})
    : valorTxt = TextEditingController(text: valor);

  int? get valor => parseValor(valorTxt.text);
}

class PagarSupervisorCubit extends Cubit<PagarSupervisorState> {
  ///Repositorios
  ///
  ///
  final _nominaRepo = sl<NominaRepo>();
  final _rutaRepo = sl<RutaRepo>();
  final _negocioRepo = sl<NegocioRepo>();

  ///Constructor
  ///
  ///
  PagarSupervisorCubit({required BuildContext context})
    : super(PagarSupervisorState(context: context, fecha: hoy())) {
    _filas.add(_nuevaFila());
    _emitFilas();
    cargar();
  }

  ///Variables
  ///
  ///
  final observacionTxt = TextEditingController();
  final conceptoOtroTxt = TextEditingController();
  final List<FilaReparto> _filas = [];
  int _siguienteKey = 0;

  @override
  Future<void> close() {
    observacionTxt.dispose();
    conceptoOtroTxt.dispose();
    for (final f in _filas) {
      f.valorTxt.dispose();
    }
    return super.close();
  }

  ///Eventos
  ///
  ///
  void seleccionarEmpleado(String? id) {
    if (id != null) emit(state.copyWith(empleadoId: id));
  }

  void cambiarConcepto(ConceptoNomina c) =>
      emit(state.copyWith(concepto: c, errorConcepto: ''));

  void cambiarFecha(DateTime f) => emit(state.copyWith(fecha: f));

  void agregarFila() {
    // No se pueden repetir rutas: no hay más filas que rutas
    if (_filas.length >= state.rutas.length) return;
    _filas.add(_nuevaFila());
    _emitFilas();
  }

  void quitarFila(FilaReparto fila) {
    if (_filas.length <= 1) return;
    _filas.remove(fila);
    // Se libera después del frame para que el TextField no lo use ya cerrado
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => fila.valorTxt.dispose(),
    );
    _emitFilas();
  }

  void cambiarRutaFila(FilaReparto fila, String? rutaId) {
    fila.rutaId = rutaId;
    _emitFilas();
  }

  void onValorChanged() => _emitFilas();

  /// Reparte [total] en partes iguales entre las filas con ruta.
  /// El residuo de la división entera va a la última ruta
  void repartirIguales(int total) {
    final filas = _filas.where((f) => f.rutaId != null).toList();
    if (filas.isEmpty) {
      AppDialogUtil.info(
        state.context,
        message: 'Primero elige las rutas entre las que se va a repartir.',
      );
      return;
    }
    final parte = total ~/ filas.length;
    final residuo = total % filas.length;
    for (var i = 0; i < filas.length; i++) {
      final v = parte + (i == filas.length - 1 ? residuo : 0);
      filas[i].valorTxt.text = '$v';
    }
    _emitFilas();
  }

  ///Peticiones
  ///
  ///
  Future<void> cargar() async {
    emit(state.copyWith(loading: true));

    final rutas = await _rutaRepo.listar();
    // TODO(backend): no hay endpoint que liste supervisores; solo se listan administradores
    final admins = await _negocioRepo.listarAdministradores();
    if (isClosed) return;

    rutas.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (r) {
        Shared.setRutas = r.data;
        emit(state.copyWith(rutas: r.data));
      },
    );
    admins.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (r) => emit(
        state.copyWith(
          empleados: r.data
              .map(
                (a) => EmpleadoNomina(
                  id: a.id,
                  nombre: '${a.nombre} ${a.apellido}'.trim(),
                  rol: 'Administrador',
                ),
              )
              .toList(),
        ),
      ),
    );
    emit(state.copyWith(loading: false));
  }

  /// Valida el formulario; true si se puede pagar
  bool validar() {
    final otro = conceptoOtroTxt.text.trim();
    final filasValidas = _filas.every(
      (f) => f.rutaId != null && (f.valor ?? 0) >= 1,
    );

    emit(
      state.copyWith(
        errorConcepto: state.concepto == ConceptoNomina.otro && otro.isEmpty
            ? 'Ingresa el concepto'
            : '',
        errorRepartos: _filas.isEmpty || !filasValidas
            ? 'Cada reparto necesita una ruta y un valor mayor a 0'
            : '',
      ),
    );

    if (state.empleadoId == null) {
      AppDialogUtil.info(state.context, message: 'Elige el empleado.');
      return false;
    }
    return state.errorConcepto == null && state.errorRepartos == null;
  }

  /// Repartos con nombre de ruta, para la confirmación
  List<(String, int)> get desglose =>
      _filas.map((f) => (state.nombreRuta(f.rutaId), f.valor ?? 0)).toList();

  /// Rutas cuyo capital conocido queda negativo con este pago
  List<String> get rutasSinCapital => _filas
      .where((f) {
        final ruta = state.rutas.where((r) => r.id == f.rutaId).firstOrNull;
        return ruta != null && (f.valor ?? 0) > ruta.capital;
      })
      .map((f) => state.nombreRuta(f.rutaId))
      .toList();

  Future<void> pagar() async {
    emit(state.copyWith(loadingBtn: true));

    final r = await _nominaRepo.pagarSupervisor(
      dto: PagoNominaSupervisorDto(
        empleadoId: state.empleadoId!,
        repartos: _filas
            .map((f) => RepartoNominaDto(rutaId: f.rutaId!, valor: f.valor!))
            .toList(),
        concepto: textoConcepto(
          state.concepto,
          conceptoOtroTxt.text,
          porDefecto: conceptoSupervisor,
        ),
        observacion: observacionTxt.text.trim(),
        fechaPago: state.fecha,
      ),
    );
    if (isClosed) return;

    final pago = r.fold((l) {
      AppDialogUtil.error(state.context, message: l.props[0].toString());
      return null;
    }, (p) => p);
    emit(state.copyWith(loadingBtn: false));
    if (pago == null) return;

    for (final f in _filas) {
      f.valorTxt.clear();
    }
    observacionTxt.clear();
    _emitFilas();
    AppDialogUtil.success(
      state.context,
      message:
          'Se registró el pago de ${MoneyUtil.format(pago.totalPagado)} repartido en ${pago.pagos.length} ${pago.pagos.length == 1 ? 'ruta' : 'rutas'}.',
    );

    // El capital de las rutas cambió
    final rutas = await _rutaRepo.listar();
    if (isClosed) return;
    rutas.fold((_) {}, (r) {
      Shared.setRutas = r.data;
      emit(state.copyWith(rutas: r.data));
    });
  }

  ///Otros
  ///
  ///
  FilaReparto _nuevaFila() => FilaReparto(key: _siguienteKey++);

  void _emitFilas() => emit(
    state.copyWith(
      filas: List.unmodifiable(_filas),
      total: _filas.fold<int>(0, (s, f) => s + (f.valor ?? 0)),
      version: state.version + 1,
      errorRepartos: '',
    ),
  );
}
