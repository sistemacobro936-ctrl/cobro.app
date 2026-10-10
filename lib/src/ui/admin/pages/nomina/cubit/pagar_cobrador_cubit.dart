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
import 'package:personal/src/domain/entities/ruta_entity.dart';
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
    _limpiarValores();
    emit(state.copyWith(empleadoId: id, limpiarCalculo: true));
  }

  void cambiarPeriodo(PeriodoNomina p) {
    _limpiarValores();
    emit(state.copyWith(periodo: p, limpiarCalculo: true));
  }

  void cambiarConcepto(ConceptoNomina c) =>
      emit(state.copyWith(concepto: c, errorConcepto: ''));

  void cambiarFecha(DateTime f) => emit(state.copyWith(fecha: f));

  /// Re-emite para refrescar total y avisos mientras se escribe
  void onValorChanged() =>
      emit(state.copyWith(errorValores: '', version: state.version + 1));

  ///Peticiones
  ///
  ///
  Future<void> cargar() async {
    emit(state.copyWith(loading: true));

    // Siempre se piden las rutas: el capital tiene que estar al día
    final rutas = await _rutaRepo.listar();
    final cobradores = await _usuarioRepo.listarCobradores();
    if (isClosed) return;

    rutas.fold((_) {}, (r) {
      Shared.setRutas = r.data;
      emit(state.copyWith(rutas: r.data));
    });
    cobradores.fold(
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

  Future<void> calcular() async {
    final id = state.empleadoId;
    if (id == null) {
      AppDialogUtil.info(
        state.context,
        message: 'Elige el cobrador para calcular la nómina.',
      );
      return;
    }

    _limpiarValores();
    emit(state.copyWith(loadingCalculo: true, limpiarCalculo: true));
    final r = await _nominaRepo.calcular(
      cobradorId: id,
      fechaInicio: DateUtil.formatDate(state.periodo.inicio),
      fechaFin: DateUtil.formatDate(state.periodo.fin),
    );
    if (isClosed) return;

    r.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (c) {
        // Cada ruta se prellena con su monto sugerido y queda editable
        for (final ruta in c.rutas) {
          final sugerido = ruta.totales.montoSugerido;
          valoresTxt[ruta.rutaId] = TextEditingController(
            text: sugerido != null && sugerido > 0 ? '$sugerido' : '',
          );
        }
        emit(
          state.copyWith(
            calculo: c,
            errorValores: '',
            comisiones: {
              ...state.comisiones,
              id: ComisionEntity(
                id: id,
                comisionBase: c.comisionBase,
                comisionPorcentaje: c.comisionPorcentaje,
              ),
            },
          ),
        );
      },
    );
    emit(state.copyWith(loadingCalculo: false));
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
        // Con la comisión nueva el cálculo ya trae base y monto sugerido
        if (state.calculo != null) calcular();
        return true;
      },
    );
  }

  /// Valida el formulario; true si se puede pagar
  bool validar() {
    final otro = conceptoOtroTxt.text.trim();

    emit(
      state.copyWith(
        errorConcepto: state.concepto == ConceptoNomina.otro && otro.isEmpty
            ? 'Ingresa el concepto'
            : '',
        errorValores: pagosPendientes.isEmpty
            ? 'Ingresa el valor a pagar en al menos una ruta'
            : '',
      ),
    );
    return state.errorConcepto == null && state.errorValores == null;
  }

  /// Rutas sin pagar con valor ≥ 1; las que quedan en blanco se omiten
  List<(RutaCalculoNominaEntity, int)> get pagosPendientes {
    final calculo = state.calculo;
    if (calculo == null) return [];
    return [
      for (final r in calculo.rutas)
        if (!state.pagadas.contains(r.rutaId))
          if (parseValor(valoresTxt[r.rutaId]?.text ?? '') case final v?
              when v >= 1)
            (r, v),
    ];
  }

  /// Un POST por ruta, en orden. Si uno falla se detiene: los anteriores
  /// ya quedaron guardados y se marcan como pagados para no repetirlos
  Future<void> pagar() async {
    final pagos = pagosPendientes;
    final concepto = textoConcepto(state.concepto, conceptoOtroTxt.text);
    final observacion = observacionTxt.text.trim();
    final pagadas = {...state.pagadas};
    final antes = pagadas.length;
    var totalPagado = 0;
    String? error;
    String? rutaFallida;

    emit(state.copyWith(loadingBtn: true));
    for (final (ruta, valor) in pagos) {
      final r = await _nominaRepo.pagarCobrador(
        dto: PagoNominaCobradorDto(
          rutaId: ruta.rutaId,
          empleadoId: state.empleadoId!,
          valor: valor,
          concepto: concepto,
          observacion: observacion,
          fechaGasto: state.fecha,
        ),
      );
      if (isClosed) return;

      error = r.fold((l) => l.props[0].toString(), (_) => null);
      if (error != null) {
        rutaFallida = ruta.rutaNombre;
        break;
      }
      pagadas.add(ruta.rutaId);
      totalPagado += valor;
      // Copia: si se pasa el mismo Set, Equatable no ve el cambio
      emit(state.copyWith(pagadas: {...pagadas}));
    }
    emit(state.copyWith(loadingBtn: false));

    final cantidad = pagadas.length - antes;
    if (error == null) {
      AppDialogUtil.success(
        state.context,
        message:
            'Se registró el pago de ${MoneyUtil.format(totalPagado)} a ${state.calculo?.cobradorNombre ?? 'el cobrador'} en $cantidad ${cantidad == 1 ? 'ruta' : 'rutas'}.',
      );
    } else {
      AppDialogUtil.error(
        state.context,
        message: cantidad == 0
            ? error
            : 'Se pagaron $cantidad ${cantidad == 1 ? 'ruta' : 'rutas'} (${MoneyUtil.format(totalPagado)}), pero falló $rutaFallida: $error\n\nLas rutas pagadas quedaron marcadas; puedes reintentar las demás.',
      );
    }

    // El capital de las rutas cambió
    if (cantidad > 0) await _refrescarRutas();
  }

  ///Otros
  ///
  ///
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

  Future<void> _refrescarRutas() async {
    final r = await _rutaRepo.listar();
    if (isClosed) return;
    r.fold((_) {}, (r) {
      Shared.setRutas = r.data;
      emit(state.copyWith(rutas: r.data));
    });
  }
}
