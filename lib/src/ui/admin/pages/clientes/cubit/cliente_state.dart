part of 'cliente_cubit.dart';

class ClienteState extends Equatable {
  final BuildContext context;
  final Widget child;
  final bool loading;
  final bool btnEnabled;
  final bool loadingBtn;
  final List<DatumClEntity>? clientes;
  final DatumREntity? ruta;
  final DatumClEntity? cliente;

  /// Buscando clientes (spinner dentro de la lista)
  final bool search;

  /// Cargando la lista de la ruta seleccionada
  final bool loadingLista;
  final bool loadingMore;

  /// Rutas para el listado; null hasta que se cargan
  final List<DatumREntity>? rutas;

  /// Ruta cuyos clientes se listan. '' = todos los clientes; null = aún sin definir
  final String? filtroRutaId;

  /// Texto de la búsqueda activa; vacío si no se está buscando
  final String busqueda;
  final PaginationEntity? paginationClientes;

  const ClienteState({
    required this.context,
    this.loading = false,
    this.btnEnabled = false,
    this.loadingBtn = false,
    this.search = false,
    this.loadingLista = false,
    this.loadingMore = false,
    this.child = const SizedBox(),
    this.clientes,
    this.ruta,
    this.cliente,
    this.rutas,
    this.filtroRutaId,
    this.busqueda = '',
    this.paginationClientes,
  });

  @override
  List<Object?> get props => [
    context,
    loading,
    btnEnabled,
    child,
    clientes ?? [],
    loadingBtn,
    ruta,
    cliente,
    search,
    loadingLista,
    loadingMore,
    rutas ?? [],
    filtroRutaId,
    busqueda,
    paginationClientes,
  ];

  ClienteState copyWith({
    BuildContext? context,
    bool? loading,
    bool? loadingBtn,
    bool? btnEnabled,
    Widget? child,
    List<DatumClEntity>? clientes,
    DatumREntity? ruta,
    DatumClEntity? cliente,
    bool limpiarRuta = false,
    bool? search,
    bool? loadingLista,
    bool? loadingMore,
    List<DatumREntity>? rutas,
    String? filtroRutaId,
    String? busqueda,
    PaginationEntity? paginationClientes,
    bool limpiarPaginacion = false,
  }) {
    return ClienteState(
      context: context ?? this.context,
      loading: loading ?? this.loading,
      btnEnabled: btnEnabled ?? this.btnEnabled,
      child: child ?? this.child,
      clientes: clientes ?? this.clientes,
      loadingBtn: loadingBtn ?? this.loadingBtn,
      ruta: limpiarRuta ? null : ruta ?? this.ruta,
      cliente: cliente ?? this.cliente,
      search: search ?? this.search,
      loadingLista: loadingLista ?? this.loadingLista,
      loadingMore: loadingMore ?? this.loadingMore,
      rutas: rutas ?? this.rutas,
      filtroRutaId: filtroRutaId ?? this.filtroRutaId,
      busqueda: busqueda ?? this.busqueda,
      paginationClientes: limpiarPaginacion
          ? null
          : paginationClientes ?? this.paginationClientes,
    );
  }
}
