part of 'historial_nomina_cubit.dart';

class HistorialNominaState extends Equatable {
  final BuildContext context;
  final bool loadingEmpleados;
  final bool loading;
  final bool loadingMore;
  final bool error;

  final List<EmpleadoNomina> empleados;
  final String? empleadoId;
  final PeriodoNomina periodo;

  final List<PagoNominaEntity> pagos;
  final ResumenNominaEntity? resumen;
  final PaginationEntity? pagination;

  const HistorialNominaState({
    required this.context,
    required this.periodo,
    this.loadingEmpleados = false,
    this.loading = false,
    this.loadingMore = false,
    this.error = false,
    this.empleados = const [],
    this.empleadoId,
    this.pagos = const [],
    this.resumen,
    this.pagination,
  });

  @override
  List<Object?> get props => [
    context,
    loadingEmpleados,
    loading,
    loadingMore,
    error,
    empleados,
    empleadoId,
    periodo,
    pagos,
    resumen,
    pagination,
  ];

  HistorialNominaState copyWith({
    bool? loadingEmpleados,
    bool? loading,
    bool? loadingMore,
    bool? error,
    List<EmpleadoNomina>? empleados,
    String? empleadoId,
    PeriodoNomina? periodo,
    List<PagoNominaEntity>? pagos,
    ResumenNominaEntity? resumen,
    PaginationEntity? pagination,
  }) => HistorialNominaState(
    context: context,
    loadingEmpleados: loadingEmpleados ?? this.loadingEmpleados,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error ?? this.error,
    empleados: empleados ?? this.empleados,
    empleadoId: empleadoId ?? this.empleadoId,
    periodo: periodo ?? this.periodo,
    pagos: pagos ?? this.pagos,
    resumen: resumen ?? this.resumen,
    pagination: pagination ?? this.pagination,
  );
}
