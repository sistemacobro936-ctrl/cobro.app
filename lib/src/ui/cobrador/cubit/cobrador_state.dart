part of 'cobrador_cubit.dart';

class CobradorRState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool btnLoading;
  final bool enabledBtn;
  final bool formGasto;
  final List<DatumREntity>? ruta;
  final List<DetalleRutaEntity>? clientes;
  final List<DetalleRutaEntity>? pagados;
  final List<DatumREntity>? resumenRuta;

  /// rutaId → cajaId. Vacío si la ruta no tiene caja abierta.
  final Map<String, String> cajaPorRuta;

  /// rutaId → gastos de esa caja. Vacío hasta que se llame listarGastos().
  final Map<String, List<GastoElementEntity>> gastosPorRuta;

  final Widget child;

  const CobradorRState({
    required this.context,
    this.btnLoading = false,
    this.loading = false,
    this.enabledBtn = false,
    this.formGasto = false,
    this.ruta,
    this.child = const SizedBox(),
    this.clientes,
    this.pagados,
    this.resumenRuta,
    this.cajaPorRuta = const {},
    this.gastosPorRuta = const {},
  });

  /// Devuelve el cajaId para una ruta dada, o null si no tiene caja.
  String? cajaId(String rutaId) => cajaPorRuta[rutaId];

  /// Devuelve los gastos de una ruta, o null si aún no se cargaron.
  List<GastoElementEntity>? gastos(String rutaId) => gastosPorRuta[rutaId];

  @override
  List<Object> get props => [
    context,
    loading,
    btnLoading,
    enabledBtn,
    ruta ?? [],
    child,
    clientes ?? [],
    pagados ?? [],
    resumenRuta ?? [],
    formGasto,
    cajaPorRuta,
    gastosPorRuta,
  ];

  CobradorRState copyWith({
    BuildContext? context,
    bool? loading,
    bool? btnLoading,
    bool? enabledBtn,
    List<DatumREntity>? ruta,
    Widget? child,
    List<DetalleRutaEntity>? clientes,
    List<DetalleRutaEntity>? pagados,
    List<DatumREntity>? resumenRuta,
    Map<String, String>? cajaPorRuta,
    Map<String, List<GastoElementEntity>>? gastosPorRuta,
    bool? formGasto,
  }) => CobradorRState(
    context: context ?? this.context,
    btnLoading: btnLoading ?? this.btnLoading,
    enabledBtn: enabledBtn ?? this.enabledBtn,
    loading: loading ?? this.loading,
    ruta: ruta ?? this.ruta,
    child: child ?? this.child,
    clientes: clientes ?? this.clientes,
    pagados: pagados ?? this.pagados,
    resumenRuta: resumenRuta ?? this.resumenRuta,
    cajaPorRuta: cajaPorRuta ?? this.cajaPorRuta,
    gastosPorRuta: gastosPorRuta ?? this.gastosPorRuta,
    formGasto: formGasto ?? this.formGasto,
  );
}
