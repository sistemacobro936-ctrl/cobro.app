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

  /// Gastos de ruta (no dependen de una caja). Solo viene en los totales
  final int gastosRuta;

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
    this.gastosRuta = 0,
  });

  /// Suma varias cajas (p. ej. todas las de una ruta en el día).
  /// Efectivo recibido y diferencia quedan pendientes (null) solo si
  /// ninguna caja los tiene todavía
  factory ResumenReporteEntity.sumar(List<ResumenReporteEntity> cajas) {
    int s(int Function(ResumenReporteEntity c) f) =>
        cajas.fold(0, (t, c) => t + f(c));
    int? sn(int? Function(ResumenReporteEntity c) f) {
      final valores = cajas.map(f).whereType<int>();
      return valores.isEmpty ? null : valores.fold<int>(0, (t, v) => t + v);
    }

    return ResumenReporteEntity(
      base: s((c) => c.base),
      efectivoRecibido: sn((c) => c.efectivoRecibido),
      cantidadRecibida: s((c) => c.cantidadRecibida),
      cantidadPrestada: s((c) => c.cantidadPrestada),
      esperadoACobrar: s((c) => c.esperadoACobrar),
      cantidadAbonos: s((c) => c.cantidadAbonos),
      cantidadPrestamos: s((c) => c.cantidadPrestamos),
      totalBoletas: s((c) => c.totalBoletas),
      valorBoletas: s((c) => c.valorBoletas),
      seguro: s((c) => c.seguro),
      gastos: s((c) => c.gastos),
      inyeccionCapital: s((c) => c.inyeccionCapital),
      retiroSeguro: s((c) => c.retiroSeguro),
      utilidad: s((c) => c.utilidad),
      diferencia: sn((c) => c.diferencia),
      gastosRuta: s((c) => c.gastosRuta),
    );
  }
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
