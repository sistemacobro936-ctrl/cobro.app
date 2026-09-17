class ResumenReporteEntity {
  final int base;
  final int? efectivoRecibido;
  final int cantidadRecibida;
  final int cantidadPrestada;
  final int esperadoACobrar;
  final int cantidadAbonos;
  final int cantidadPrestamos;
  final int totalBoletas;
  final int valorBoletas;
  final int seguro;
  final int gastos;
  final int inyeccionCapital;
  final int retiroSeguro;
  final int utilidad;
  final int? diferencia;

  ResumenReporteEntity({
    required this.base,
    this.efectivoRecibido,
    required this.cantidadRecibida,
    required this.cantidadPrestada,
    required this.esperadoACobrar,
    required this.cantidadAbonos,
    required this.cantidadPrestamos,
    required this.totalBoletas,
    required this.valorBoletas,
    required this.seguro,
    required this.gastos,
    required this.inyeccionCapital,
    required this.retiroSeguro,
    required this.utilidad,
    this.diferencia,
  });
}

class DatumReporteCajaEntity extends ResumenReporteEntity {
  final String cajaId;
  final String rutaId;
  final String rutaNombre;
  final DateTime fechaOperacion;
  final String estado;

  DatumReporteCajaEntity({
    required this.cajaId,
    required this.rutaId,
    required this.rutaNombre,
    required this.fechaOperacion,
    required this.estado,
    required super.base,
    super.efectivoRecibido,
    required super.cantidadRecibida,
    required super.cantidadPrestada,
    required super.esperadoACobrar,
    required super.cantidadAbonos,
    required super.cantidadPrestamos,
    required super.totalBoletas,
    required super.valorBoletas,
    required super.seguro,
    required super.gastos,
    required super.inyeccionCapital,
    required super.retiroSeguro,
    required super.utilidad,
    super.diferencia,
  });
}

class ReporteCajaEntity {
  final bool exito;
  final String msg;
  final DatumReporteCajaEntity? data;

  ReporteCajaEntity({required this.exito, required this.msg, this.data});
}

class ReporteNegocioDataEntity {
  final ResumenReporteEntity totales;
  final List<DatumReporteCajaEntity> cajas;

  ReporteNegocioDataEntity({required this.totales, required this.cajas});
}

class ReporteNegocioEntity {
  final bool exito;
  final String msg;
  final ReporteNegocioDataEntity? data;

  ReporteNegocioEntity({required this.exito, required this.msg, this.data});
}
