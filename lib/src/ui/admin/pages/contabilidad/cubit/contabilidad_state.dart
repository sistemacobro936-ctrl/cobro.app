part of 'contabilidad_cubit.dart';

class ContabilidadState extends Equatable {
  final BuildContext context;
  final bool loading;
  final DateTime fecha;
  final List<DatumREntity> rutas;

  /// null = todas las rutas
  final DatumREntity? rutaSeleccionada;
  final ResumenReporteEntity? totales;

  /// Todas las cajas del día (una ruta puede tener varias)
  final List<DatumReporteCajaEntity> cajas;

  /// null = suma de las cajas visibles
  final DatumReporteCajaEntity? cajaSeleccionada;

  const ContabilidadState({
    required this.context,
    required this.fecha,
    this.loading = false,
    this.rutas = const [],
    this.rutaSeleccionada,
    this.totales,
    this.cajas = const [],
    this.cajaSeleccionada,
  });

  /// Cajas de la ruta seleccionada, o todas si no hay ruta
  List<DatumReporteCajaEntity> get cajasVisibles {
    final ruta = rutaSeleccionada;
    return ruta == null ? cajas : cajas.where((c) => c.rutaId == ruta.id).toList();
  }

  /// Lo que se muestra: una caja, la suma de las cajas de la ruta o los
  /// totales del negocio. null si la ruta no tuvo cajas ese día
  ResumenReporteEntity? get reporte {
    if (cajaSeleccionada != null) return cajaSeleccionada;
    if (rutaSeleccionada == null) return totales;
    final visibles = cajasVisibles;
    return visibles.isEmpty ? null : ResumenReporteEntity.sumar(visibles);
  }

  @override
  List<Object?> get props => [
    context,
    loading,
    fecha,
    rutas,
    rutaSeleccionada,
    totales,
    cajas,
    cajaSeleccionada,
  ];

  ContabilidadState copyWith({
    bool? loading,
    DateTime? fecha,
    List<DatumREntity>? rutas,
    DatumREntity? rutaSeleccionada,
    bool limpiarRuta = false,
    ResumenReporteEntity? totales,
    bool limpiarTotales = false,
    List<DatumReporteCajaEntity>? cajas,
    DatumReporteCajaEntity? cajaSeleccionada,
    bool limpiarCaja = false,
  }) => ContabilidadState(
    context: context,
    loading: loading ?? this.loading,
    fecha: fecha ?? this.fecha,
    rutas: rutas ?? this.rutas,
    rutaSeleccionada: limpiarRuta
        ? null
        : rutaSeleccionada ?? this.rutaSeleccionada,
    totales: limpiarTotales ? null : totales ?? this.totales,
    cajas: cajas ?? this.cajas,
    cajaSeleccionada: limpiarCaja
        ? null
        : cajaSeleccionada ?? this.cajaSeleccionada,
  );
}
