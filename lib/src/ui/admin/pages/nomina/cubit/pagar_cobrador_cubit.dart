import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/domain/repository/nomina_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/domain/repository/usuario_repo.dart';
import 'package:personal/src/ui/admin/pages/nomina/nomina_util.dart';

part 'pagar_cobrador_state.dart';

class PagarCobradorCubit extends Cubit<PagarCobradorState> {
  ///Repositorios
  ///
  ///
  final _nominaRepo = sl<NominaRepo>();
  final _rutaRepo = sl<RutaRepo>();
  final _usuarioRepo = sl<UsuarioRepository>();

  ///Constructor
  ///
  ///
  PagarCobradorCubit({required BuildContext context})
    : super(
        PagarCobradorState(
          context: context,
          periodo: PeriodoNomina.mesActual(),
          fecha: hoy(),
        ),
      ) {
    cargar();
  }

  ///Variables
  ///
  ///
  final observacionTxt = TextEditingController();
  final conceptoOtroTxt = TextEditingController();

  /// Valor a pagar de cada ruta del cálculo (rutaId → controller)
  final Map<String, TextEditingController> valoresTxt = {};

  @override
  Future<void> close() {
    observacionTxt.dispose();
    conceptoOtroTxt.dispose();
    _limpiarValores();
    return super.close();
  }

  ///Eventos
  ///
  ///
  void seleccionarEmpleado(String? id) {
    if (id == null || id == state.empleadoId) return;
    emit(state.copyWith(empleadoId: id, limpiarPagadas: true));
    calcular();
  }

  void cambiarPeriodo(PeriodoNomina p) {
    emit(state.copyWith(periodo: p, limpiarPagadas: true));
    calcular();
  }

  /// Nómina / Seguro: cada uno tiene su propio cálculo
  void cambiarTipo(ConceptoCalculo t) {
    if (t == state.tipo) return;
    emit(state.copyWith(tipo: t));
    calcular();
  }

  void cambiarConcepto(ConceptoNomina c) =>
      emit(state.copyWith(concepto: c, errorConcepto: ''));

  void cambiarFecha(DateTime f) => emit(state.copyWith(fecha: f));

  /// Re-emite para refrescar avisos mientras se escribe
  void onValorChanged() => emit(state.copyWith(version: state.version + 1));

  ///Peticiones
  ///
  ///
  Future<void> cargar() async {
    emit(state.copyWith(loading: true));

    final r = await _usuarioRepo.listarCobradores();
    if (isClosed) return;

    r.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (r) {
        Shared.setCobradores = r.data;
        emit(
          state.copyWith(
            empleados: r.data
                .map(
                  (c) => EmpleadoNomina(
                    id: c.id,
                    nombre: '${c.nombre} ${c.apellido}'.trim(),
                    rol: 'Cobrador',
                    comision: c.comision,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    emit(state.copyWith(loading: false));
  }

  /// [conservarValores]: tras un pago se mantiene lo digitado en las demás rutas
  Future<void> calcular({bool conservarValores = false}) async {
    final previos = conservarValores
        ? {for (final e in valoresTxt.entries) e.key: e.value.text}
        : const <String, String>{};
    final id = state.empleadoId;
    if (id == null) return;
    final tipo = state.tipo;
    final periodo = state.periodo;

    _limpiarValores();
    emit(
      state.copyWith(
        loadingCalculo: true,
        limpiarCalculo: true,
        disponibles: const {},
      ),
    );
    final r = await _nominaRepo.calcular(
      cobradorId: id,
      concepto: tipo,
      fechaInicio: DateUtil.formatDate(state.periodo.inicio),
      fechaFin: DateUtil.formatDate(state.periodo.fin),
    );
    // Si cambió algún filtro mientras se calculaba, este resultado ya no aplica
    if (isClosed ||
        state.empleadoId != id ||
        state.tipo != tipo ||
        state.periodo != periodo) {
      return;
    }

    final calculo = r.fold((l) {
      AppDialogUtil.error(state.context, message: l.props[0].toString());
      return null;
    }, (c) => c);
    emit(state.copyWith(loadingCalculo: false));
    if (calculo == null) return;

    // NÓMINA: valor vacío, lo digita el admin. SEGURO: prellenado con el sugerido
    for (final ruta in calculo.rutas) {
      final sugerido = ruta.totales.montoSugerido;
      valoresTxt[ruta.rutaId] = TextEditingController(
        text:
            previos[ruta.rutaId] ??
            (tipo == ConceptoCalculo.seguro && sugerido != null && sugerido > 0
                ? '$sugerido'
                : ''),
      );
    }
    emit(
      state.copyWith(
        calculo: calculo,
        comisiones: calculo.comisionPorcentaje == null
            ? null
            : {
                ...state.comisiones,
                id: ComisionEntity(
                  id: id,
                  comisionPorcentaje: calculo.comisionPorcentaje,
                ),
              },
      ),
    );

    await _cargarDisponibles(calculo);
  }

  /// Devuelve true si se guardó; si falla muestra el error
  Future<bool> guardarComision(ComisionDto dto) async {
    final id = state.empleadoId;
    if (id == null) return false;

    final r = await _usuarioRepo.actualizarComision(id: id, dto: dto);
    if (isClosed) return false;

    return r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        return false;
      },
      (c) {
        emit(state.copyWith(comisiones: {...state.comisiones, id: c}));
        // El sugerido del seguro depende del %
        if (state.tipo == ConceptoCalculo.seguro) calcular();
        return true;
      },
    );
  }

  /// Valida el pago de una ruta; devuelve el valor o null (y muestra por qué)
  int? validarPago(RutaCalculoNominaEntity ruta) {
    final valor = parseValor(valoresTxt[ruta.rutaId]?.text ?? '');
    String? error;

    if (valor == null || valor < 1) {
      error = 'Ingresa el valor a pagar de ${ruta.rutaNombre}.';
    } else if (state.tipo == ConceptoCalculo.nomina &&
        state.concepto == ConceptoNomina.otro &&
        conceptoOtroTxt.text.trim().isEmpty) {
      emit(state.copyWith(errorConcepto: 'Ingresa el concepto'));
      error = 'Ingresa el concepto del pago.';
    }

    if (error != null) {
      AppDialogUtil.info(state.context, message: error);
      return null;
    }
    return valor;
  }

  /// Concepto del pago: "Seguro" en la pestaña Seguro; si no, Nómina/Prima/Otro
  String get conceptoPago => state.tipo == ConceptoCalculo.seguro
      ? 'Seguro'
      : textoConcepto(state.concepto, conceptoOtroTxt.text)!;

  /// Nómina sale del capital de la ruta; seguro, de los seguros de la ruta
  Future<void> pagar(RutaCalculoNominaEntity ruta, int valor) async {
    emit(state.copyWith(pagando: ruta.rutaId));
    final r = await _nominaRepo.pagarCobrador(
      dto: PagoNominaCobradorDto(
        rutaId: ruta.rutaId,
        empleadoId: state.empleadoId!,
        valor: valor,
        tipo: state.tipo,
        concepto: conceptoPago,
        observacion: observacionTxt.text.trim(),
        fechaPago: state.fecha,
      ),
    );
    if (isClosed) return;
    _despuesDePagar(
      r.fold((l) => l.props[0].toString(), (_) => null),
      ruta,
      valor,
    );
  }

  ///Otros
  ///
  ///
  void _despuesDePagar(String? error, RutaCalculoNominaEntity ruta, int valor) {
    emit(state.copyWith(limpiarPagando: true));
    if (error != null) {
      AppDialogUtil.error(state.context, message: error);
      return;
    }

    emit(
      state.copyWith(
        pagadas: {...state.pagadas, state.claveRuta(ruta.rutaId): valor},
      ),
    );
    AppDialogUtil.success(
      state.context,
      message:
          'Se pagaron ${MoneyUtil.format(valor)} de ${conceptoPago.toLowerCase()} en ${ruta.rutaNombre}.',
    );
    // Recarga el cálculo junto con el disponible de cada ruta
    calcular(conservarValores: true);
  }

  Future<void> _cargarDisponibles(CalculoNominaEntity calculo) async {
    final disponibles = <String, int>{};
    for (final ruta in calculo.rutas) {
      final r = await _rutaRepo.movimiento(idRuta: ruta.rutaId);
      r.fold((_) {}, (m) => disponibles[ruta.rutaId] = m.data.disponible+m.data.seguros);
    }
    if (isClosed || state.calculo != calculo) return;
    emit(state.copyWith(disponibles: disponibles));
  }

  void _limpiarValores() {
    final controllers = valoresTxt.values.toList();
    valoresTxt.clear();
    // Se liberan después del frame para que ningún TextField los use ya cerrados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }
}
