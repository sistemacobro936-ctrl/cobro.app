part of 'ruta_cubit.dart';

class RutaState extends Equatable {
  final BuildContext context;
  final Widget child;
  final bool loading;
  final DatumCEntity? cobrador;
  final bool loadingBtn;
  final bool enabled;
  final List<DatumREntity>? rutas;
  final List<DatumClEntity>? clientes;
  final PaginationEntity? paginationClientes;
  final DataMovimientoE? movimiento;
  final int pageClientes;
  final List<DatumCajaEntity>? historico;

  /// Bitácora de eventos ("movimientos") de la ruta que se está viendo
  final String? rutaMovimientos;
  final List<DatumMovimientoLogEntity>? movimientosRuta;
  final PaginationEntity? paginationMovimientos;
  final bool loadingMovimientos;
  final bool loadingMasMovimientos;

  const RutaState({
    required this.context,
    this.child = const SizedBox(),
    this.loading = false,
    this.cobrador,
    this.loadingBtn = false,
    this.enabled = false,
    this.rutas,
    this.clientes,
    this.movimiento,
    this.paginationClientes,
    this.pageClientes=1,
    this.historico,
    this.rutaMovimientos,
    this.movimientosRuta,
    this.paginationMovimientos,
    this.loadingMovimientos = false,
    this.loadingMasMovimientos = false,

  });

  @override
  List<Object?> get props => [
    context,
    child,
    loading,
    cobrador,
    loadingBtn,
    rutas,
    enabled,
    clientes ?? [],
    movimiento,
    paginationClientes,
    pageClientes,
    historico,
    rutaMovimientos,
    movimientosRuta ?? [],
    paginationMovimientos,
    loadingMovimientos,
    loadingMasMovimientos,
  ];

  RutaState copyWith({
    BuildContext? context,
    Widget? child,
    bool? loading,
    DatumCEntity? cobrador,
    bool? loadingBtn,
    bool? enabled,
    List<DatumREntity>? rutas,
    List<DatumClEntity>? clientes,
    bool limpiarCobrador = false,
    bool limpiarPaginacion = false,
    DataMovimientoE? movimiento,
    PaginationEntity? paginationClientes,
    List<DatumCajaEntity>? historico,
    String? rutaMovimientos,
    List<DatumMovimientoLogEntity>? movimientosRuta,
    PaginationEntity? paginationMovimientos,
    bool? loadingMovimientos,
    bool? loadingMasMovimientos,
    bool limpiarMovimientos = false,


    int? pageClientes,
  }) => RutaState(
    context: context ?? this.context,
    child: child ?? this.child,
    loading: loading ?? this.loading,
    cobrador: limpiarCobrador ? null : cobrador ?? this.cobrador,
    loadingBtn: loadingBtn ?? this.loadingBtn,
    rutas: rutas ?? this.rutas,
    enabled: enabled ?? this.enabled,
    clientes: limpiarPaginacion?[]: clientes ?? this.clientes,
    movimiento: movimiento ?? this.movimiento,
    paginationClientes:  paginationClientes ?? this.paginationClientes,
        pageClientes: pageClientes?? this.pageClientes,
    historico: historico??  this.historico,
    rutaMovimientos: rutaMovimientos ?? this.rutaMovimientos,
    movimientosRuta: limpiarMovimientos
        ? null
        : movimientosRuta ?? this.movimientosRuta,
    paginationMovimientos: limpiarMovimientos
        ? null
        : paginationMovimientos ?? this.paginationMovimientos,
    loadingMovimientos: loadingMovimientos ?? this.loadingMovimientos,
    loadingMasMovimientos: loadingMasMovimientos ?? this.loadingMasMovimientos,
  );
}
