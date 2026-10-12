part of 'prestamo_cubit.dart';

class PrestamoState extends Equatable {
  final BuildContext context;
  final Widget child;
  final DatumClEntity? cliente;
  final SCobroEntity? periodoSeleccionado;
  final DateTime? fechaInicial;
  final DateTime? fechaFinal;
  final bool listClientes;
  final bool loading;
  final bool isPrevious;
  final bool aplicaSeguro;
  final bool loadingBtn;
  final bool loadingInfoCliente;
  final List<DateTime>? fechasPago;
  final List<DatumPEntity>? prestamos;
  final List<CuotaEsperada>? cuotaEsperada;
  final DatumPEntity? prestamo;

  /// Estado de los préstamos listados: ACTIVO, PAGADO, CANCELADO o TODOS
  final String filtroEstado;
  const PrestamoState({
    required this.context,
    this.child = const SizedBox(),
    this.listClientes = true,
    this.cliente,
    this.periodoSeleccionado,
    this.fechaInicial,
    this.fechaFinal,
    this.fechasPago,
    this.loading = false,
    this.isPrevious = false,
    this.aplicaSeguro = true,
    this.loadingBtn = false,
    this.loadingInfoCliente = false,
    this.prestamos,
    this.prestamo,
    this.cuotaEsperada,
    this.filtroEstado = 'ACTIVO',
  });

  @override
  List<Object?> get props => [
    context,
    listClientes,
    child,
    cliente,
    periodoSeleccionado,
    fechaInicial ?? DateTime.now(),
    fechaFinal,
    fechasPago,
    loading,
    isPrevious,
    aplicaSeguro,
    loadingBtn,
    loadingInfoCliente,
    prestamos,
    prestamo,
    cuotaEsperada,
    filtroEstado,
  ];
  PrestamoState copyWith({
    BuildContext? context,
    bool? listClientes,
    Widget? child,
    DatumClEntity? cliente,
    SCobroEntity? periodoSeleccionado,
    DateTime? fechaInicial,
    DateTime? fechaFinal,
    List<DateTime>? fechasPago,
    bool? loading,
    bool? isPrevious,
    bool? aplicaSeguro,
    bool? loadingBtn,
    bool? loadingInfoCliente,
    List<DatumPEntity>? prestamos,
    DatumPEntity? prestamo,
    bool limpiarCliente = false,
    bool limpiarPeriodo = false,
    List<CuotaEsperada>? cuotaEsperada,
    String? filtroEstado,
  }) => PrestamoState(
    context: context ?? this.context,
    listClientes: listClientes ?? this.listClientes,
    child: child ?? this.child,
    cliente: limpiarCliente ? null : cliente ?? this.cliente,
    periodoSeleccionado: limpiarPeriodo
        ? null
        : periodoSeleccionado ?? this.periodoSeleccionado,
    fechaInicial: fechaInicial ?? this.fechaInicial,
    fechaFinal: fechaFinal ?? this.fechaFinal,
    fechasPago: fechasPago ?? this.fechasPago,
    loading: loading ?? this.loading,
    isPrevious: isPrevious ?? this.isPrevious,
    aplicaSeguro: aplicaSeguro ?? this.aplicaSeguro,
    loadingBtn: loadingBtn ?? this.loadingBtn,
    loadingInfoCliente: loadingInfoCliente ?? this.loadingInfoCliente,
    prestamos: prestamos ?? this.prestamos,
    prestamo: prestamo ?? this.prestamo,
    cuotaEsperada: cuotaEsperada ?? this.cuotaEsperada,
    filtroEstado: filtroEstado ?? this.filtroEstado,
  );
}
