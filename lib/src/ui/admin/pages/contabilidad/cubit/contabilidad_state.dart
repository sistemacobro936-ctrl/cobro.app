part of 'contabilidad_cubit.dart';

class ContabilidadState extends Equatable {
  final BuildContext context;
  final bool loading;
  final DateTime fecha;
  final List<DatumREntity> rutas;
  final DatumREntity? rutaSeleccionada;
  final ResumenReporteEntity? totales;
  final List<DatumReporteCajaEntity> cajas;
  final DatumReporteCajaEntity? cajaRuta;

  const ContabilidadState({
    required this.context,
    required this.fecha,
    this.loading = false,
    this.rutas = const [],
    this.rutaSeleccionada,
    this.totales,
    this.cajas = const [],
    this.cajaRuta,
  });

  @override
  List<Object?> get props => [
    context,
    loading,
    fecha,
    rutas,
    rutaSeleccionada,
    totales,
    cajas,
    cajaRuta,
  ];

  ContabilidadState copyWith({
    BuildContext? context,
    bool? loading,
    DateTime? fecha,
    List<DatumREntity>? rutas,
    DatumREntity? rutaSeleccionada,
    ResumenReporteEntity? totales,
    List<DatumReporteCajaEntity>? cajas,
    DatumReporteCajaEntity? cajaRuta,
  }) => ContabilidadState(
    context: context ?? this.context,
    loading: loading ?? this.loading,
    fecha: fecha ?? this.fecha,
    rutas: rutas ?? this.rutas,
    rutaSeleccionada: rutaSeleccionada ?? this.rutaSeleccionada,
    totales: totales ?? this.totales,
    cajas: cajas ?? this.cajas,
    cajaRuta: cajaRuta ?? this.cajaRuta,
  );
}
