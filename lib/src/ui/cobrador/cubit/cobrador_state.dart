part of 'cobrador_cubit.dart';

class CobradorRState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool btnLoading;
  final bool enabledBtn;
  final bool formGasto;

  final bool buscando;
  final List<DatumREntity>? ruta;
  final List<DetalleRutaEntity>? clientes;
  final List<DetalleRutaEntity>? pagados;
  final List<DetalleRutaEntity>? noPagados;

  /// prestamoId → no pago registrado hoy
  final Map<String, NoPagoRutaEntity> noPagosInfo;
  final List<DatumREntity>? resumenRuta;

  /// rutaId → cajaId. Vacío si la ruta no tiene caja abierta.
  final Map<String, String> cajaPorRuta;

  /// rutaId → gastos de esa caja. Vacío hasta que se llame listarGastos().
  final Map<String, List<GastoElementEntity>> gastosPorRuta;

  final Widget child;

  final bool buscoAlgunaVez;
  final bool loadingBtn;

  final DatumClEntity? cliente;

  final bool loadingConfig;
  final List<SCobroEntity> periodos;
  final SCobroEntity? periodoSeleccionado;

  final bool aplicaSeguro;
  final DateTime? fechaInicial;
  final DateTime? fechaFinal;
  final List<DateTime>? fechasPago;

  const CobradorRState({
    required this.context,
    this.btnLoading = false,
    this.aplicaSeguro = false,
    this.buscoAlgunaVez = false,
    this.loadingBtn = false,
    this.periodos = const [],
    this.periodoSeleccionado,
    this.fechaFinal,
    this.fechaInicial,
    this.loadingConfig = false,
    this.loading = false,
    this.enabledBtn = false,
    this.formGasto = false,
    this.buscando = false,

    this.ruta,
    this.child = const SizedBox(),
    this.clientes,
    this.pagados,
    this.noPagados,
    this.noPagosInfo = const {},
    this.resumenRuta,
    this.cajaPorRuta = const {},
    this.gastosPorRuta = const {},
    this.cliente,
    this.fechasPago,
  });

  /// Devuelve el cajaId para una ruta dada, o null si no tiene caja.
  String? cajaId(String rutaId) => cajaPorRuta[rutaId];

  /// Devuelve los gastos de una ruta, o null si aún no se cargaron.
  List<GastoElementEntity>? gastos(String rutaId) => gastosPorRuta[rutaId];

  @override
  List<Object?> get props => [
    context,
    loading,
    btnLoading,
    enabledBtn,
    ruta ?? [],
    child,
    clientes ?? [],
    pagados ?? [],
    noPagados ?? [],
    noPagosInfo,
    resumenRuta ?? [],
    formGasto,
    cajaPorRuta,
    gastosPorRuta,
    buscando,
    buscoAlgunaVez,
    cliente,
    loadingConfig,
    periodos,
    periodoSeleccionado,

    aplicaSeguro,
    fechaInicial,
    fechaFinal,
    fechasPago,
    loadingBtn
  ];

  CobradorRState copyWith({
    BuildContext? context,
    bool? loading,
    bool? btnLoading,
    bool? enabledBtn,
    bool? loadingBtn,
    List<DatumREntity>? ruta,
    Widget? child,
    List<DetalleRutaEntity>? clientes,
    List<DetalleRutaEntity>? pagados,
    List<DetalleRutaEntity>? noPagados,
    Map<String, NoPagoRutaEntity>? noPagosInfo,
    List<DatumREntity>? resumenRuta,
    Map<String, String>? cajaPorRuta,
    Map<String, List<GastoElementEntity>>? gastosPorRuta,
    bool? buscando,
    bool? formGasto,
    bool? buscoAlgunaVez,
    DatumClEntity? cliente,
    bool? loadingConfig,
    List<SCobroEntity>? periodos,
    SCobroEntity? periodoSeleccionado,
    bool? aplicaSeguro,
    bool limpiarCliente = false,
    DateTime? fechaInicial,
    DateTime? fechaFinal,
    List<DateTime>? fechasPago,
  }) => CobradorRState(
    context: context ?? this.context,
    btnLoading: btnLoading ?? this.btnLoading,
    enabledBtn: enabledBtn ?? this.enabledBtn,
    loading: loading ?? this.loading,
    ruta: ruta ?? this.ruta,
    child: child ?? this.child,
    clientes: clientes ?? this.clientes,
    pagados: pagados ?? this.pagados,
    noPagados: noPagados ?? this.noPagados,
    noPagosInfo: noPagosInfo ?? this.noPagosInfo,
    resumenRuta: resumenRuta ?? this.resumenRuta,
    cajaPorRuta: cajaPorRuta ?? this.cajaPorRuta,
    gastosPorRuta: gastosPorRuta ?? this.gastosPorRuta,
    formGasto: formGasto ?? this.formGasto,
    buscando: buscando ?? this.buscando,
    buscoAlgunaVez: buscoAlgunaVez ?? this.buscoAlgunaVez,
    cliente: limpiarCliente ? null : cliente ?? this.cliente,
    loadingConfig: loadingConfig ?? this.loadingConfig,
    periodos: periodos ?? this.periodos,
    periodoSeleccionado: periodoSeleccionado ?? this.periodoSeleccionado,
    aplicaSeguro: aplicaSeguro ?? this.aplicaSeguro,
    fechaInicial: fechaInicial ?? this.fechaInicial,
    fechaFinal: fechaFinal ?? this.fechaFinal,
    fechasPago: fechasPago ?? this.fechasPago,
    loadingBtn: loadingBtn ?? this.loadingBtn,
  );
}
