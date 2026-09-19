import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/crear_prestamo_dto.dart';
import 'package:personal/src/domain/dto/cuota_esperada_dto.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/dto/prestamo_fecha_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/config_entity.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';
import 'package:personal/src/domain/repository/config_repo.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';
import 'package:personal/src/domain/repository/presamo_repo.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/home_cubit.dart';
import 'package:personal/src/ui/admin/pages/prestamos/resumen_previo.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/prestamos_home.dart';

part 'prestamo_state.dart';

class PrestamoCubit extends Cubit<PrestamoState> {
  ///repositorios
  ///
  final _clientRep = sl<ClienteRepository>();
  final _configRepo = sl<ConfiguracionRepository>();
  final _prestamosRepo = sl<PresamoRepo>();
  final _pagoRepo = sl<PagoRepo>();

  ///Constructor
  ///
  ///

  PrestamoCubit(BuildContext context) : super(PrestamoState(context: context)) {
    onGetChild(PrestamosHome());
    onGetFechaInicial(DateTime.now());
    listarClientes();
    listarConfig();
  }

  ///Variables
  ///
  ///
  final montoController = TextEditingController();
  final interesController = TextEditingController();
  final seguroController = TextEditingController();
  final seguroValorController = TextEditingController();
  final cuotasController = TextEditingController();

  static const maxCuotas = 365;

  ///Eventos
  ///
  ///
  void onGetChild(Widget c) {
    emit(state.copyWith(child: c));
  }

  void onGetClient(DatumClEntity c) {
    emit(state.copyWith(cliente: c));
  }

  /// Al elegir la frecuencia, las cuotas toman el valor por defecto de esa
  /// frecuencia; el usuario puede modificarlas después.
  void onGetPeriodo(SCobroEntity p) {
    cuotasController.text = p.cuotas?.toString() ?? '';
    emit(state.copyWith(periodoSeleccionado: p));
  }

  void restablecerCuotas() {
    cuotasController.text = state.periodoSeleccionado?.cuotas?.toString() ?? '';
    fechaFinal();
  }

  void onAplicaSeguro(bool aplica) {
    emit(state.copyWith(aplicaSeguro: aplica));
    if (aplica) recalcularSeguro();
  }

  /// Valor del seguro = monto × %. Se puede editar a mano; cambiar el monto
  /// o el % lo vuelve a calcular.
  void recalcularSeguro() {
    final monto = int.tryParse(montoController.text) ?? 0;
    final pct = num.tryParse(seguroController.text) ?? 0;
    final valor = (monto * pct / 100).round();

    seguroValorController.text = monto > 0 && pct > 0 ? '$valor' : '';
  }

  /// Una fecha inicial anterior a hoy marca el préstamo como existente
  void onGetFechaInicial(DateTime f) {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final esAnterior = DateUtils.dateOnly(f).isBefore(hoy);

    emit(state.copyWith(fechaInicial: f, isPrevious: esAnterior));
  }

  void onEventPrevious() {
    emit(state.copyWith(isPrevious: !state.isPrevious));
  }

  void onEventListClient(bool e) {
    emit(state.copyWith(listClientes: e));
  }

  ///Peticioness
  ///
  ///
  void listarClientes() async {
    emit(state.copyWith(loading: true));
    if (Shared.getClientes == null || Shared.getClientes!.isEmpty) {
      final r = await _clientRep.listar();
      r.fold((l) {}, (r) {
        Shared.setClientes=r.data;
      });
    }
    emit(state.copyWith(loading: false));
  }

  void listarConfig() async {
    emit(state.copyWith(loading: true));

    if (Shared.getConfig == null) {
      final r = await _configRepo.obtenerConfiguracion();
      r.fold((l) {}, (r) {
        Shared.setConfig = r.data;
      });
    }
    interesController.value = interesController.value.copyWith(
      text: Shared.getConfig!.configuracion.interesDefault.toString(),
    );
    seguroController.value = seguroController.value.copyWith(
      text: Shared.getConfig!.configuracion.seguroDefault.toString(),
    );
    recalcularSeguro();
    emit(state.copyWith(loading: false));
  }

  void crearPrestamo() async {
    emit(state.copyWith(loadingBtn: true));

    final interes =
        (int.parse(montoController.text) *
                (int.parse(interesController.text) / 100))
            .toInt();
    final cuota =
        ((int.parse(montoController.text) + interes) /
                numeroCuotas)
            .toInt();
    final r = await _prestamosRepo.crear(
      dto: CrearPrestamoDto(
        valorSeguro: valorSeguro,
        clienteId: state.cliente!.id,
        monto: int.parse(montoController.text),
        interes: int.parse(interesController.text),
        numeroCuotas: numeroCuotas,
        montoInteres: interes,
        valorCuota: cuota,
        frecuencia: state.periodoSeleccionado!.codigo!,
        fechaInicio: DateUtil.formatDate(state.fechaInicial!),
        fechaFin: DateUtil.formatDate(state.fechaFinal!),
        fechas:
            state.periodoSeleccionado!.codigo == "SEMANAL" ||
                state.periodoSeleccionado!.codigo == "QUINCENAL"
            ? state.fechasPago!
                  .asMap()
                  .entries
                  .map(
                    (entry) => PrestamoFechaDto(
                      fechaPago: DateUtil.formatDate(entry.value),
                      numero: entry.key + 1,
                      valor: cuota,
                    ),
                  )
                  .toList()
            : [],
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Prestamo creado con éxito.",
        );
        state.context.read<HomeCubit>().onCurrenteIndex(2);
        state.context.read<HomeCubit>().onCurrenteIndex(3);
        onGetChild(PrestamosHome());
        listarPrestamo();
        emit(state.copyWith(cliente: null, periodoSeleccionado: null));
        montoController.clear();
      },
    );
    emit(state.copyWith(loadingBtn: false));
  }

  void crearPrestamoExistente() async {
    emit(state.copyWith(loadingBtn: true));

    final interes =
        (int.parse(montoController.text) *
                (int.parse(interesController.text) / 100))
            .toInt();
    final cuota =
        ((int.parse(montoController.text) + interes) /
                numeroCuotas)
            .toInt();
    final r = await _prestamosRepo.crearHistorico(
      dto: CrearPrestamoDto(
        clienteId: state.cliente!.id,
        valorSeguro: valorSeguro,
        monto: int.parse(montoController.text),
        interes: int.parse(interesController.text),
        numeroCuotas: numeroCuotas,
        montoInteres: interes,
        valorCuota: cuota,
        frecuencia: state.periodoSeleccionado!.codigo!,
        fechaInicio: DateUtil.formatDate(state.fechaInicial!),
        fechaFin: DateUtil.formatDate(state.fechaFinal!),
        pagos: state.cuotaEsperada!
            .where((e) => e.esPasada)
            .map(
              (e) => PagoDto(
                prestamoId: "",
                valor: e.monto.toInt(),
                fechaPago: e.fechaCobro,
              ),
            )
            .toList(),
        fechas:
            state.periodoSeleccionado!.codigo == "SEMANAL" ||
                state.periodoSeleccionado!.codigo == "QUINCENAL"
            ? state.fechasPago!
                  .asMap()
                  .entries
                  .map(
                    (entry) => PrestamoFechaDto(
                      fechaPago: DateUtil.formatDate(entry.value),
                      numero: entry.key + 1,
                      valor: cuota,
                    ),
                  )
                  .toList()
            : [],
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Prestamo creado con éxito.",
        );
        state.context.read<HomeCubit>().onCurrenteIndex(2);
        state.context.read<HomeCubit>().onCurrenteIndex(3);
        onGetChild(PrestamosHome());
        listarPrestamo();
        emit(state.copyWith(cliente: null, periodoSeleccionado: null));
        montoController.clear();
      },
    );
    emit(state.copyWith(loadingBtn: false));
  }

  Future<void> clinteId() async {
    emit(state.copyWith(loading: true));
    final r = await _clientRep.obtenerCliente(id: Shared.getIdClient);
    r.fold((l) {}, (r) {
      emit(state.copyWith(cliente: r));
    });
    emit(state.copyWith(loading: false));
  }

  void listarPrestamo() async {
    emit(state.copyWith(loading: true));
    final r = await _prestamosRepo.listar();
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(prestamos: r.data));
      },
    );
    emit(state.copyWith(loading: false));
  }

  void detallePrestamo(String id) async {
    emit(state.copyWith(loading: true));
    final r = await _prestamosRepo.detallePrestamo(id: id);

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(prestamo: r));
      },
    );
    emit(state.copyWith(loading: false));
  }

  Future<bool> revertirPago({
    required String pagoId,
  }) async {
    emit(state.copyWith(loadingBtn: true));
    final r = await _pagoRepo.revertirPago(
     idPago: pagoId
    );
    emit(state.copyWith(loadingBtn: false));

    return r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        return false;
      },
      (_) {
        // Refresca el detalle para que los pagos muestren el nuevo estado
        if (state.prestamo != null) {
          detallePrestamo(state.prestamo!.id);
        }
        return true;
      },
    );
  }

  ///Navegacion
  ///
  ///
  void goToPrevious() {
    final capital = int.tryParse(montoController.text) ?? 0;
    final interes = int.tryParse(interesController.text) ?? 0;

    final periodo = state.periodoSeleccionado;

    if (capital <= 0 || periodo == null) {
      return;
    }

    final totalCuotas = numeroCuotas;

    if (totalCuotas <= 0 || state.fechaInicial == null) {
      return;
    }

    // ─────────────────────────────────────────────
    // 1. Calcular interés
    // ─────────────────────────────────────────────

    final totalInteres = (capital * interes / 100).round();

    // Total que debe pagar el cliente
    final totalPrestamo = capital + totalInteres;

    // ─────────────────────────────────────────────
    // 2. Generar fechas de pago
    // ─────────────────────────────────────────────

    // ─────────────────────────────────────────────
    // 3. Generar cuotas
    // ─────────────────────────────────────────────

    final cuotas = _generarCuotasEsperadas(
      fechasPago: state.fechasPago!,
      totalPrestamo: totalPrestamo,
      totalCuotas: totalCuotas,
    );

    // ─────────────────────────────────────────────
    // 4. Mostrar resumen
    // ─────────────────────────────────────────────

    emit(state.copyWith(cuotaEsperada: cuotas));
    onGetChild(ResumenPrevio(cuotas: cuotas));
  }

  ///Otros
  ///
  ///

  void fechaFinal() {
    final fechas = generarFechasPago();

    if (fechas.isEmpty) {
      emit(state.copyWith(fechaFinal: null, fechasPago: []));

      return;
    }

    emit(state.copyWith(fechaFinal: fechas.last, fechasPago: fechas));
  }

  List<DateTime> generarFechasPago() {
    final config = Shared.getConfig;

    final fechaInicial = state.fechaInicial;
    final periodo = state.periodoSeleccionado;

    if (config == null || fechaInicial == null || periodo == null) {
      return [];
    }

    final cuotas = numeroCuotas;

    if (cuotas <= 0) {
      return [];
    }

    final diasPago = config.diasCobro
        .where((e) => e.habilitado && e.diaSemana != null)
        .map((e) => e.diaSemana!)
        .toSet();

    if (diasPago.isEmpty) {
      return [];
    }

    final fechas = <DateTime>[];

    var fecha = fechaInicial;

    for (var i = 0; i < cuotas; i++) {
      fecha = _calcularSiguienteFechaPago(
        fechaActual: fecha,
        periodo: periodo,
        diasPago: diasPago,
      );

      fechas.add(fecha);
    }

    return fechas;
  }

  DateTime _calcularSiguienteFechaPago({
    required DateTime fechaActual,
    required dynamic periodo,
    required Set<int> diasPago,
  }) {
    final codigo = periodo.codigo?.toUpperCase();

    DateTime fecha;

    switch (codigo) {
      case 'DIARIO':
        fecha = fechaActual.add(const Duration(days: 1));
        break;
      case 'SEMANAL':
        fecha = fechaActual.add(const Duration(days: 7));
        break;

      case 'QUINCENAL':
        fecha = fechaActual.add(const Duration(days: 15));
        break;
      case 'MENSUAL':
        fecha = fechaActual.add(const Duration(days: 30));
        break;

      default:
        fecha = fechaActual.add(Duration(days: periodo.cantidadDias ?? 1));
    }

    // Buscar el siguiente día habilitado
    // para realizar el cobro.
    while (!diasPago.contains(fecha.weekday)) {
      fecha = fecha.add(const Duration(days: 1));
    }

    return fecha;
  }

  List<CuotaEsperada> _generarCuotasEsperadas({
    required List<DateTime> fechasPago,
    required int totalPrestamo,
    required int totalCuotas,
  }) {
    if (fechasPago.isEmpty || totalCuotas <= 0) {
      return [];
    }

    final hoy = DateTime.now();

    // Cuota base
    final cuotaBase = totalPrestamo ~/ totalCuotas;

    // Lo que queda después de repartir
    final diferencia = totalPrestamo - (cuotaBase * totalCuotas);

    return fechasPago.asMap().entries.map((entry) {
      final index = entry.key;
      final fecha = entry.value;

      // La última cuota absorbe el sobrante
      final monto = index == totalCuotas - 1
          ? cuotaBase + diferencia
          : cuotaBase;

      final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

      final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

      return CuotaEsperada(
        numero: index + 1,
        fechaCobro: fechaSinHora,
        // La cuota de hoy no cuenta: el día aún no termina
        esPasada: fechaSinHora.isBefore(hoySinHora),
        monto: monto.toDouble(),
      );
    }).toList();
  }

  /// Valor del seguro a cobrar: 0 si el seguro está desactivado
  int get valorSeguro =>
      state.aplicaSeguro ? (int.tryParse(seguroValorController.text) ?? 0) : 0;

  /// Cuotas del préstamo: las de la frecuencia por defecto o las que editó el
  /// usuario. 0 si no hay frecuencia o el valor no es válido.
  int get numeroCuotas {
    if (state.periodoSeleccionado == null) return 0;
    final n = int.tryParse(cuotasController.text.trim()) ?? 0;
    return n > 0 && n <= maxCuotas ? n : 0;
  }

  String? get cuotasError {
    final texto = cuotasController.text.trim();
    if (texto.isEmpty || numeroCuotas > 0) return null;
    return 'Ingresa entre 1 y $maxCuotas cuotas';
  }

  void clear() {
    emit(
      state.copyWith(
        limpiarCliente: true,
        limpiarPeriodo: true,
        isPrevious: false,
        aplicaSeguro: true,
        fechaInicial: DateTime.now(),
      ),
    );
    montoController.clear();
    cuotasController.clear();
    seguroValorController.clear();
  }
}
