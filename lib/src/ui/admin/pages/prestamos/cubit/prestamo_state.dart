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
  final bool loadingBtn;
  final List<DateTime>? fechasPago;
  final List<DatumPEntity>? prestamos;
  final List<CuotaEsperada>? cuotaEsperada;
  final DatumPEntity? prestamo;
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
    this.loadingBtn = false,
    this.prestamos,
    this.prestamo,
    this.cuotaEsperada,
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
    loadingBtn,
    prestamos,
    prestamo,
    cuotaEsperada
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
    bool? loadingBtn,
    List<DatumPEntity>? prestamos,
    DatumPEntity? prestamo,
    bool limpiarCliente = false,
    bool limpiarPeriodo = false,
    List<CuotaEsperada>? cuotaEsperada,
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
    loadingBtn: loadingBtn ?? this.loadingBtn,
    prestamos: prestamos ?? this.prestamos,
    prestamo: prestamo ?? this.prestamo,
    cuotaEsperada: cuotaEsperada ?? this.cuotaEsperada
  );
}
