part of 'pagar_supervisor_cubit.dart';

class PagarSupervisorState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingBtn;

  final List<DatumREntity> rutas;
  final List<EmpleadoNomina> empleados;
  final String? empleadoId;

  /// Nómina (sale del capital de cada ruta) o Seguro (de sus seguros)
  final ConceptoCalculo tipo;
  final ConceptoNomina concepto;
  final DateTime fecha;

  final List<FilaReparto> filas;
  final int total;

  /// Las filas son mutables: la versión fuerza el rebuild
  final int version;

  final String? errorConcepto;
  final String? errorRepartos;

  const PagarSupervisorState({
    required this.context,
    required this.fecha,
    this.loading = false,
    this.loadingBtn = false,
    this.rutas = const [],
    this.empleados = const [],
    this.empleadoId,
    this.tipo = ConceptoCalculo.nomina,
    this.concepto = ConceptoNomina.nomina,
    this.filas = const [],
    this.total = 0,
    this.version = 0,
    this.errorConcepto,
    this.errorRepartos,
  });

  EmpleadoNomina? get empleado =>
      empleados.where((e) => e.id == empleadoId).firstOrNull;

  bool get seguro => tipo == ConceptoCalculo.seguro;

  /// Lo que hay para pagar en la ruta según el tipo (capital o seguros)
  int disponibleRuta(DatumREntity ruta) => seguro ? ruta.seguros : ruta.capital;

  String nombreRuta(String? id) =>
      rutas.where((r) => r.id == id).firstOrNull?.nombre ?? '';

  /// Rutas que se pueden elegir en [fila] (no repetidas en otras filas)
  List<DatumREntity> rutasDisponibles(FilaReparto fila) {
    final usadas = filas
        .where((f) => f.key != fila.key)
        .map((f) => f.rutaId)
        .toSet();
    return rutas.where((r) => !usadas.contains(r.id)).toList();
  }

  @override
  List<Object?> get props => [
    context,
    loading,
    loadingBtn,
    rutas,
    empleados,
    empleadoId,
    tipo,
    concepto,
    fecha,
    filas,
    total,
    version,
    errorConcepto,
    errorRepartos,
  ];

  /// Los errores se limpian pasando '' (string vacío)
  PagarSupervisorState copyWith({
    bool? loading,
    bool? loadingBtn,
    List<DatumREntity>? rutas,
    List<EmpleadoNomina>? empleados,
    String? empleadoId,
    ConceptoCalculo? tipo,
    ConceptoNomina? concepto,
    DateTime? fecha,
    List<FilaReparto>? filas,
    int? total,
    int? version,
    String? errorConcepto,
    String? errorRepartos,
  }) => PagarSupervisorState(
    context: context,
    loading: loading ?? this.loading,
    loadingBtn: loadingBtn ?? this.loadingBtn,
    rutas: rutas ?? this.rutas,
    empleados: empleados ?? this.empleados,
    empleadoId: empleadoId ?? this.empleadoId,
    tipo: tipo ?? this.tipo,
    concepto: concepto ?? this.concepto,
    fecha: fecha ?? this.fecha,
    filas: filas ?? this.filas,
    total: total ?? this.total,
    version: version ?? this.version,
    errorConcepto: errorConcepto == null
        ? this.errorConcepto
        : (errorConcepto.isEmpty ? null : errorConcepto),
    errorRepartos: errorRepartos == null
        ? this.errorRepartos
        : (errorRepartos.isEmpty ? null : errorRepartos),
  );
}
