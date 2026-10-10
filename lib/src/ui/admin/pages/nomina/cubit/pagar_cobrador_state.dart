part of 'pagar_cobrador_cubit.dart';

class PagarCobradorState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingCalculo;

  /// Ruta que se está pagando en este momento
  final String? pagando;

  final List<EmpleadoNomina> empleados;
  final String? empleadoId;
  final PeriodoNomina periodo;

  /// Pestaña: Nómina (valor digitado) o Seguro (% de la boleta)
  final ConceptoCalculo tipo;
  final CalculoNominaEntity? calculo;

  /// Disponible de cada ruta (`GET /ruta/movimiento/:id`)
  final Map<String, int> disponibles;

  /// Pagos hechos en esta pantalla ("tipo-rutaId" → valor)
  final Map<String, int> pagadas;

  /// % de boleta conocido por cobrador (del listado, del cálculo o al guardarlo)
  final Map<String, ComisionEntity> comisiones;

  /// Solo NÓMINA: Nómina / Prima / Otro
  final ConceptoNomina concepto;
  final DateTime fecha;
  final String? errorConcepto;

  /// Los valores viven en controllers: la versión fuerza el rebuild
  final int version;

  const PagarCobradorState({
    required this.context,
    required this.periodo,
    required this.fecha,
    this.loading = false,
    this.loadingCalculo = false,
    this.pagando,
    this.empleados = const [],
    this.empleadoId,
    this.tipo = ConceptoCalculo.nomina,
    this.calculo,
    this.disponibles = const {},
    this.pagadas = const {},
    this.comisiones = const {},
    this.concepto = ConceptoNomina.nomina,
    this.errorConcepto,
    this.version = 0,
  });

  EmpleadoNomina? get empleado =>
      empleados.where((e) => e.id == empleadoId).firstOrNull;

  ComisionEntity? get comision => comisiones[empleadoId] ?? empleado?.comision;

  String claveRuta(String rutaId) => '${tipo.api}-$rutaId';

  int? pagado(String rutaId) => pagadas[claveRuta(rutaId)];

  @override
  List<Object?> get props => [
    context,
    loading,
    loadingCalculo,
    pagando,
    empleados,
    empleadoId,
    periodo,
    tipo,
    calculo,
    disponibles,
    pagadas,
    comisiones,
    concepto,
    fecha,
    errorConcepto,
    version,
  ];

  /// Los errores se limpian pasando '' (string vacío)
  PagarCobradorState copyWith({
    bool? loading,
    bool? loadingCalculo,
    String? pagando,
    bool limpiarPagando = false,
    List<EmpleadoNomina>? empleados,
    String? empleadoId,
    PeriodoNomina? periodo,
    ConceptoCalculo? tipo,
    CalculoNominaEntity? calculo,
    bool limpiarCalculo = false,
    Map<String, int>? disponibles,
    Map<String, int>? pagadas,
    bool limpiarPagadas = false,
    Map<String, ComisionEntity>? comisiones,
    ConceptoNomina? concepto,
    DateTime? fecha,
    String? errorConcepto,
    int? version,
  }) => PagarCobradorState(
    context: context,
    loading: loading ?? this.loading,
    loadingCalculo: loadingCalculo ?? this.loadingCalculo,
    pagando: limpiarPagando ? null : pagando ?? this.pagando,
    empleados: empleados ?? this.empleados,
    empleadoId: empleadoId ?? this.empleadoId,
    periodo: periodo ?? this.periodo,
    tipo: tipo ?? this.tipo,
    calculo: limpiarCalculo ? null : calculo ?? this.calculo,
    disponibles: disponibles ?? this.disponibles,
    // Otro cobrador u otro período empieza sin pagos marcados
    pagadas: limpiarPagadas ? const {} : pagadas ?? this.pagadas,
    comisiones: comisiones ?? this.comisiones,
    concepto: concepto ?? this.concepto,
    fecha: fecha ?? this.fecha,
    errorConcepto: errorConcepto == null
        ? this.errorConcepto
        : (errorConcepto.isEmpty ? null : errorConcepto),
    version: version ?? this.version,
  );
}
