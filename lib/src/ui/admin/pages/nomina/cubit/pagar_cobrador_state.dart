part of 'pagar_cobrador_cubit.dart';

class PagarCobradorState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingCalculo;
  final bool loadingBtn;

  /// Todas las rutas del admin, para conocer su capital
  final List<DatumREntity> rutas;
  final List<EmpleadoNomina> empleados;
  final String? empleadoId;

  final PeriodoNomina periodo;
  final CalculoNominaEntity? calculo;

  /// Rutas del cálculo actual que ya se pagaron
  final Set<String> pagadas;

  /// Comisiones conocidas por empleado (del listado, del cálculo o al guardarlas)
  final Map<String, ComisionEntity> comisiones;

  final ConceptoNomina concepto;
  final DateTime fecha;
  final String? errorValores;
  final String? errorConcepto;

  /// Los valores viven en controllers: la versión fuerza el rebuild
  final int version;

  const PagarCobradorState({
    required this.context,
    required this.periodo,
    required this.fecha,
    this.loading = false,
    this.loadingCalculo = false,
    this.loadingBtn = false,
    this.rutas = const [],
    this.empleados = const [],
    this.empleadoId,
    this.calculo,
    this.pagadas = const {},
    this.comisiones = const {},
    this.concepto = ConceptoNomina.nomina,
    this.errorValores,
    this.errorConcepto,
    this.version = 0,
  });

  EmpleadoNomina? get empleado =>
      empleados.where((e) => e.id == empleadoId).firstOrNull;

  ComisionEntity? get comision => comisiones[empleadoId] ?? empleado?.comision;

  /// Capital actual de una ruta, si se conoce
  int? capitalRuta(String rutaId) =>
      rutas.where((r) => r.id == rutaId).firstOrNull?.capital;

  @override
  List<Object?> get props => [
    context,
    loading,
    loadingCalculo,
    loadingBtn,
    rutas,
    empleados,
    empleadoId,
    periodo,
    calculo,
    pagadas,
    comisiones,
    concepto,
    fecha,
    errorValores,
    errorConcepto,
    version,
  ];

  /// Los errores se limpian pasando '' (string vacío)
  PagarCobradorState copyWith({
    bool? loading,
    bool? loadingCalculo,
    bool? loadingBtn,
    List<DatumREntity>? rutas,
    List<EmpleadoNomina>? empleados,
    String? empleadoId,
    PeriodoNomina? periodo,
    CalculoNominaEntity? calculo,
    bool limpiarCalculo = false,
    Set<String>? pagadas,
    Map<String, ComisionEntity>? comisiones,
    ConceptoNomina? concepto,
    DateTime? fecha,
    String? errorValores,
    String? errorConcepto,
    int? version,
  }) => PagarCobradorState(
    context: context,
    loading: loading ?? this.loading,
    loadingCalculo: loadingCalculo ?? this.loadingCalculo,
    loadingBtn: loadingBtn ?? this.loadingBtn,
    rutas: rutas ?? this.rutas,
    empleados: empleados ?? this.empleados,
    empleadoId: empleadoId ?? this.empleadoId,
    periodo: periodo ?? this.periodo,
    calculo: limpiarCalculo ? null : calculo ?? this.calculo,
    // Un cálculo nuevo empieza sin rutas pagadas
    pagadas: limpiarCalculo ? const {} : pagadas ?? this.pagadas,
    comisiones: comisiones ?? this.comisiones,
    concepto: concepto ?? this.concepto,
    fecha: fecha ?? this.fecha,
    errorValores: errorValores == null
        ? this.errorValores
        : (errorValores.isEmpty ? null : errorValores),
    errorConcepto: errorConcepto == null
        ? this.errorConcepto
        : (errorConcepto.isEmpty ? null : errorConcepto),
    version: version ?? this.version,
  );
}
