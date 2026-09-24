import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/crear_prestamo_dto.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/dto/prestamo_fecha_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/config_entity.dart'
    show SCobroEntity;
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/domain/entities/pago_ruta_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';
import 'package:personal/src/domain/repository/config_repo.dart';
import 'package:personal/src/domain/repository/gastos_repo.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';
import 'package:personal/src/domain/repository/presamo_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/ui/cobrador/c_home.dart';
import 'package:personal/src/ui/cobrador/clientes.dart';

part 'cobrador_state.dart';

class CobradorRCubit extends Cubit<CobradorRState> {
  final _rutaRepo = sl<RutaRepo>();
  final _pagoRepo = sl<PagoRepo>();
  final _gastoRepo = sl<GastosRepo>();
  final _clienteRepo = sl<ClienteRepository>();
  final _configRepo = sl<ConfiguracionRepository>();
  final _prestamosRepo = sl<PresamoRepo>();

  static const maxCuotas = 365;

  CobradorRCubit({required BuildContext context})
    : super(CobradorRState(context: context)) {
    onEventChild(CHome());
    calculaterFecha();
    _cargarConfig();
  }

  ///variables
  ///
  ///
  final concepto = TextEditingController();
  final valor = TextEditingController();
  final observacion = TextEditingController();
  final cedulaController = TextEditingController();
  final montoController = TextEditingController();
  final interesController = TextEditingController();
  final seguroController = TextEditingController();
  final seguroValorController = TextEditingController();
  final cuotasController = TextEditingController();

  ///Eventos
  ///
  ///
  void onEventChild(Widget c) {
    emit(state.copyWith(child: c));
  }

  void calculaterFecha() {
    onGetFechaInicial(DateTime.now());
  }

  void onGetFechaInicial(DateTime f) {
    emit(state.copyWith(fechaInicial: f));
    fechaFinal();
  }

  void fechaFinal() {
    final fechas = generarFechasPago();

    if (fechas.isEmpty) {
      emit(state.copyWith(fechasPago: []));
      return;
    }

    emit(state.copyWith(fechaFinal: fechas.last, fechasPago: fechas));
  }

  void onAplicaSeguro(bool aplica) {
    emit(state.copyWith(aplicaSeguro: aplica));
    if (aplica) recalcularSeguro();
  }

  void onGetPeriodo(SCobroEntity p) {
    cuotasController.text = p.cuotas?.toString() ?? '';
    emit(state.copyWith(periodoSeleccionado: p));
    fechaFinal();
  }

  ///Validaciones
  ///
  ///
  void validarForm() {
    bool e = false;

    if (concepto.text.isNotEmpty && valor.text.isNotEmpty) {
      e = true;
    }
    emit(state.copyWith(formGasto: e));
  }

  ///Peticiones
  ///
  ///
  ///
  void infoRuta() async {
    emit(state.copyWith(loading: true));
    final r = await _rutaRepo.rutaCobrador();
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(ruta: r.data));
      },
    );
    // Sin rutas asignadas no hay resumen ni gastos que consultar
    if (tieneRutas) {
      await resumenRuta();
      await listarGastos();
    }

    emit(state.copyWith(loading: false));
  }

  void clientesRuta() async {
    if (!tieneRutas) return;
    emit(state.copyWith(loading: true));

    final rutas = state.ruta!;
    final idRutas = rutas.map((e) => e.id).join(',');
    final fecha = DateUtil.formatDate(DateTime.now());

    // Los no pagos de hoy se piden en paralelo, una petición por ruta
    final noPagosFuture = Future.wait(
      rutas.map((ruta) => _pagoRepo.noPagosRuta(rutaId: ruta.id, fecha: fecha)),
    );

    final r = await _rutaRepo.detalleRuta(idRuta: idRutas, esCobro: true);

    final noPagosInfo = <String, NoPagoRutaEntity>{};
    for (final resultado in await noPagosFuture) {
      resultado.fold(
        // Si falla no se bloquea el cobro: solo no se separan los no pagados
        (l) => log("no-pagos: $l"),
        (lista) {
          for (final n in lista) {
            noPagosInfo[n.prestamoId] = n;
          }
        },
      );
    }

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (clientes) {
        final List<DetalleRutaEntity> pendientes = [];
        final List<DetalleRutaEntity> pagados = [];
        final List<DetalleRutaEntity> noPagados = [];

        for (final item in clientes) {
          final prestamos = item.cliente.prestamos;

          if (prestamos == null || prestamos.isEmpty) {
            pendientes.add(item);
            continue;
          }

          bool tienePagado = false;
          bool tieneNoPagado = false;
          bool tienePendiente = false;

          for (final prestamo in prestamos) {
            if (prestamo.yaPago == true) {
              tienePagado = true;
            } else if (noPagosInfo.containsKey(prestamo.id)) {
              // Registrado como no pago hoy: ya no es "pendiente"
              tieneNoPagado = true;
            } else {
              tienePendiente = true;
            }
          }

          if (tienePagado) pagados.add(item);
          if (tieneNoPagado) noPagados.add(item);
          if (tienePendiente) pendientes.add(item);
        }

        emit(
          state.copyWith(
            clientes: pendientes,
            pagados: pagados,
            noPagados: noPagados,
            noPagosInfo: noPagosInfo,
          ),
        );

        onEventChild(Clientes());
      },
    );

    emit(state.copyWith(loading: false));
  }

  Future<void> buscarCliente() async {
    final cedula = cedulaController.text.trim();
    if (cedula.isEmpty) return;

    emit(
      state.copyWith(
        buscando: true,
        buscoAlgunaVez: true,
        limpiarCliente: true,
      ),
    );

    final r = await _clienteRepo.buscar(q: cedula);
    final match = r.fold<DatumClEntity?>((l) => null, (res) {
      for (final c in res.data) {
        if (c.cedula.trim() == cedula) return c;
      }
      return null;
    });

    if (match == null) {
      if (!isClosed) emit(state.copyWith(buscando: false));
      return;
    }

    // Se trae el detalle completo para tener sus préstamos
    final detalle = await _clienteRepo.obtenerCliente(id: match.id);
    final cliente = detalle.fold((l) => match, (d) => d);

    if (isClosed) return;
    emit(state.copyWith(cliente: cliente, buscando: false));
  }

  Future<void> resumenRuta() async {
    if (!tieneRutas) return;
    emit(state.copyWith(loading: true));
    final idRutas = state.ruta!.map((e) => e.id).join(',');

    final r = await _rutaRepo.resumen(idsRuta: idRutas);
    r.fold(
      (l) {
        log("aaaa $l");
      },
      (r) {
        // Construye rutaId → cajaId de forma plana para acceso O(1)
        final cajaPorRuta = <String, String>{
          for (final datum in r.data)
            for (final caja in datum.gestionRuta ?? []) caja.rutaId: caja.id,
        };
        emit(state.copyWith(resumenRuta: r.data, cajaPorRuta: cajaPorRuta));
      },
    );
    emit(state.copyWith(loading: false));
  }

  Future<void> listarGastos() async {
    emit(state.copyWith(loading: true));

    // Una petición por cada ruta que tenga caja
    final resultado = <String, List<GastoElementEntity>>{};

    await Future.wait(
      state.cajaPorRuta.entries.map((entry) async {
        final rutaId = entry.key;
        final cajaId = entry.value;
        final r = await _gastoRepo.listarGastos(cajaId: cajaId);
        r.fold(
          (l) => resultado[rutaId] = [],
          (gastos) => resultado[rutaId] = gastos.data.gastos,
        );
      }),
    );

    emit(state.copyWith(gastosPorRuta: resultado, loading: false));
  }

  void pagar({required String prestamoId, required int valorPago}) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _pagoRepo.pagar(
      dto: PagoDto(
        prestamoId: prestamoId,
        valor: valorPago,
        fechaPago: DateTime.now(),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        clientesRuta();
      },
    );
    emit(state.copyWith(btnLoading: false));
  }

  void noPago({
    required String prestamoId,
    required MotivoNoPago motivo,
    String? observacion,
    DateTime? fechaPromesa,
  }) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _pagoRepo.noPago(
      dto: NoPagoDto(
        prestamoId: prestamoId,
        motivo: motivo,
        observacion: observacion,
        fechaPromesa: fechaPromesa,
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        clientesRuta();
      },
    );
    emit(state.copyWith(btnLoading: false));
  }

  /// Revierte un pago y refresca el resumen y la lista de clientes
  Future<bool> revertirPago({required String pagoId}) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _pagoRepo.revertirPago(idPago: pagoId);
    emit(state.copyWith(btnLoading: false));

    final ok = r.fold((l) {
      AppDialogUtil.error(state.context, message: l.props[0].toString());
      return false;
    }, (_) => true);

    if (ok) {
      await resumenRuta();
      clientesRuta();
    }
    return ok;
  }

  Future<void> _cargarConfig() async {
    emit(state.copyWith(loadingConfig: true));

    if (Shared.getConfig == null) {
      final r = await _configRepo.obtenerConfiguracion();
      r.fold((l) {}, (r) => Shared.setConfig = r.data);
    }

    final config = Shared.getConfig;
    if (config != null) {
      interesController.text = config.configuracion.interesDefault.toString();
      seguroController.text = config.configuracion.seguroDefault.toString();
      recalcularSeguro();
      emit(state.copyWith(periodos: config.periodosCobro));
    }

    emit(state.copyWith(loadingConfig: false));
  }

  void crearGasto({required String idCaja}) async {
    emit(state.copyWith(loading: true));
    final r = await _gastoRepo.crearGasto(
      dto: CrearGastoDto(
        cajaId: idCaja,
        concepto: concepto.text,
        valor: int.parse(valor.text),
        observacion: observacion.text,
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(state.context, message: "Operación exitosa.");
        clear();
      },
    );
    await resumenRuta();
    await listarGastos();
    emit(state.copyWith(loading: false));
  }

  ///
  ///

  ///Otros
  ///
  ///

  bool get tieneRutas => state.ruta != null && state.ruta!.isNotEmpty;

  /// Nombre de la ruta de un cliente encontrado. Solo se conocen los nombres
  /// de las rutas del propio cobrador (Shared.getRutas no aplica aquí: el
  /// cobrador no consulta /ruta, solo su rutaCobrador()); si el préstamo es
  /// de otra ruta, se avisa igual pero sin poder mostrar su nombre.
  String nombreRuta(String rutaId) {
    if (rutaId.isEmpty) return 'Sin ruta asignada';
    for (final r in state.ruta ?? <DatumREntity>[]) {
      if (r.id == rutaId) return r.nombre;
    }
    return 'Otra ruta (no asignada a ti)';
  }

  int get totalClientes => (state.ruta ?? []).fold(
    0,
    (total, ruta) => total + ruta.cantidadClientes,
  );
  int get valorSeguro =>
      state.aplicaSeguro ? (int.tryParse(seguroValorController.text) ?? 0) : 0;

  /// Cuotas del préstamo: las de la frecuencia por defecto o las que editó el
  /// usuario. 0 si no hay frecuencia o el valor no es válido.
  int get numeroCuotas {
    if (state.periodoSeleccionado == null) return 0;
    final n = int.tryParse(cuotasController.text.trim()) ?? 0;
    return n > 0 && n <= maxCuotas ? n : 0;
  }

  void clear() {
    valor.clear();
    observacion.clear();
    concepto.clear();
  }

  void limpiarBusqueda() {
    cedulaController.clear();
    emit(state.copyWith(limpiarCliente: true, buscoAlgunaVez: false));
  }

  List<DateTime> generarFechasPago() {
    final config = Shared.getConfig;
    final fechaInicial = state.fechaInicial;
    final periodo = state.periodoSeleccionado;

    if (config == null || fechaInicial == null || periodo == null) return [];

    final cuotas = numeroCuotas;
    if (cuotas <= 0) return [];

    final diasPago = config.diasCobro
        .where((e) => e.habilitado && e.diaSemana != null)
        .map((e) => e.diaSemana!)
        .toSet();

    if (diasPago.isEmpty) return [];

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
    required SCobroEntity periodo,
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

    while (!diasPago.contains(fecha.weekday)) {
      fecha = fecha.add(const Duration(days: 1));
    }

    return fecha;
  }

  void recalcularSeguro() {
    final monto = int.tryParse(montoController.text) ?? 0;
    final pct = num.tryParse(seguroController.text) ?? 0;
    final valor = (monto * pct / 100).round();

    seguroValorController.text = monto > 0 && pct > 0 ? '$valor' : '';
  }

  /// Crea el préstamo para el cliente encontrado en el buscador de "Nuevo
  /// préstamo" del cobrador. Propia del cobrador: no usa PrestamoCubit/admin.
  Future<void> crearPrestamo() async {
    final cliente = state.cliente;
    final periodo = state.periodoSeleccionado;
    final monto = int.tryParse(montoController.text) ?? 0;
    final interesPct = int.tryParse(interesController.text) ?? 0;
    final cuotas = numeroCuotas;

    if (cliente == null ||
        periodo == null ||
        monto <= 0 ||
        cuotas <= 0 ||
        state.fechaInicial == null ||
        state.fechaFinal == null) {
      return;
    }

    emit(state.copyWith(loadingBtn: true));

    final interes = (monto * (interesPct / 100)).toInt();
    final cuota = ((monto + interes) / cuotas).toInt();

    final r = await _prestamosRepo.crear(
      dto: CrearPrestamoDto(
        clienteId: cliente.id,
        valorSeguro: valorSeguro,
        monto: monto,
        interes: interesPct,
        numeroCuotas: cuotas,
        montoInteres: interes,
        valorCuota: cuota,
        frecuencia: periodo.codigo!,
        fechaInicio: DateUtil.formatDate(state.fechaInicial!),
        fechaFin: DateUtil.formatDate(state.fechaFinal!),
        fechas: periodo.codigo == 'SEMANAL' || periodo.codigo == 'QUINCENAL'
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
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (_) => AppDialogUtil.success(
        state.context,
        message: 'Préstamo creado con éxito.',
        onPressed: () {
          montoController.clear();
          cedulaController.clear();
          emit(state.copyWith(limpiarCliente: true, buscoAlgunaVez: false));
          if (Navigator.of(state.context).canPop()) {
            Navigator.of(state.context).pop();
          }
        },
      ),
    );

    emit(state.copyWith(loadingBtn: false));
  }
}
