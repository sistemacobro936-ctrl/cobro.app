part of 'atrasados_cubit.dart';

class AtrasadosState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingMore;
  final List<AtrasadoEntity> atrasados;
  final ResumenMoraEntity? resumen;
  final PaginationEntity? pagination;

  /// Índice del rango seleccionado; null = todos
  final int? nivel;
  final bool soloClavos;

  const AtrasadosState({
    required this.context,
    this.loading = false,
    this.loadingMore = false,
    this.atrasados = const [],
    this.resumen,
    this.pagination,
    this.nivel,
    this.soloClavos = false,
  });

  @override
  List<Object?> get props => [
    context,
    loading,
    loadingMore,
    atrasados,
    resumen,
    pagination,
    nivel,
    soloClavos,
  ];

  AtrasadosState copyWith({
    bool? loading,
    bool? loadingMore,
    List<AtrasadoEntity>? atrasados,
    ResumenMoraEntity? resumen,
    PaginationEntity? pagination,
    bool limpiarPaginacion = false,
    int? nivel,
    bool limpiarNivel = false,
    bool? soloClavos,
  }) {
    return AtrasadosState(
      context: context,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      atrasados: atrasados ?? this.atrasados,
      resumen: resumen ?? this.resumen,
      pagination: limpiarPaginacion ? null : pagination ?? this.pagination,
      nivel: limpiarNivel ? null : nivel ?? this.nivel,
      soloClavos: soloClavos ?? this.soloClavos,
    );
  }
}
