part of 'actividad_cubit.dart';

class ActividadState extends Equatable {
  final bool loading;
  final bool loadingMore;
  final bool error;

  /// null = todos los tipos
  final TipoActividad? tipo;
  final List<ActividadEntity> items;
  final PaginationEntity? pagination;

  const ActividadState({
    this.loading = false,
    this.loadingMore = false,
    this.error = false,
    this.tipo,
    this.items = const [],
    this.pagination,
  });

  @override
  List<Object?> get props => [
    loading,
    loadingMore,
    error,
    tipo,
    items,
    pagination,
  ];

  ActividadState copyWith({
    bool? loading,
    bool? loadingMore,
    bool? error,
    TipoActividad? tipo,
    bool clearTipo = false,
    List<ActividadEntity>? items,
    PaginationEntity? pagination,
  }) => ActividadState(
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error ?? this.error,
    tipo: clearTipo ? null : (tipo ?? this.tipo),
    items: items ?? this.items,
    pagination: pagination ?? this.pagination,
  );
}
