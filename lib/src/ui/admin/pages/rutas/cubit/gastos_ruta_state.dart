part of 'gastos_ruta_cubit.dart';

class GastosRutaState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingMore;
  final bool error;

  /// Primer día del mes que se está viendo
  final DateTime mes;
  final List<GastoRutaEntity> gastos;
  final ResumenGastosRutaEntity? resumen;
  final PaginationEntity? pagination;

  const GastosRutaState({
    required this.context,
    required this.mes,
    this.loading = false,
    this.loadingMore = false,
    this.error = false,
    this.gastos = const [],
    this.resumen,
    this.pagination,
  });

  @override
  List<Object?> get props => [
    context,
    mes,
    loading,
    loadingMore,
    error,
    gastos,
    resumen,
    pagination,
  ];

  GastosRutaState copyWith({
    DateTime? mes,
    bool? loading,
    bool? loadingMore,
    bool? error,
    List<GastoRutaEntity>? gastos,
    ResumenGastosRutaEntity? resumen,
    PaginationEntity? pagination,
  }) => GastosRutaState(
    context: context,
    mes: mes ?? this.mes,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error ?? this.error,
    gastos: gastos ?? this.gastos,
    resumen: resumen ?? this.resumen,
    pagination: pagination ?? this.pagination,
  );
}
