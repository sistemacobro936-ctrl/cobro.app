/// Movimientos de una caja: inyecciones y retiros de capital, retiros de
/// seguro, pagos dobles, pagos menores, préstamos nuevos y reembolsos del día
class MovimientosCajaEntity {
  final MovimientosCajaInfoEntity caja;
  final ResumenMovimientosEntity resumen;
  final List<InyeccionCapitalEntity> inyeccionesCapital;
  final List<InyeccionCapitalEntity> retirosCapital;
  final List<InyeccionCapitalEntity> retirosSeguro;
  final List<PagoDobleEntity> pagosDobles;
  final List<PagoMenorEntity> pagosMenores;
  final List<PrestamoDelDiaEntity> prestamosDelDia;
  final List<PrestamoDelDiaEntity> reembolsosDelDia;

  MovimientosCajaEntity({
    required this.caja,
    required this.resumen,
    required this.inyeccionesCapital,
    required this.retirosCapital,
    required this.retirosSeguro,
    required this.pagosDobles,
    required this.pagosMenores,
    required this.prestamosDelDia,
    required this.reembolsosDelDia,
  });
}

class MovimientosCajaInfoEntity {
  final String id;
  final String rutaId;
  final String rutaNombre;
  final String fechaOperacion;
  final String estado;

  MovimientosCajaInfoEntity({
    required this.id,
    required this.rutaId,
    required this.rutaNombre,
    required this.fechaOperacion,
    required this.estado,
  });
}

class ResumenMovimientosEntity {
  final int cantidadInyecciones;
  final num totalInyectado;
  final int cantidadRetirosCapital;
  final num totalRetiradoCapital;
  final int cantidadRetirosSeguro;
  final num totalRetiradoSeguro;
  final int cantidadPagosDobles;
  final int cantidadPagosMenores;
  final num faltanteTotal;
  final int cantidadPrestamos;
  final num totalPrestado;
  final int cantidadReembolsos;
  final num totalReembolsado;

  ResumenMovimientosEntity({
    required this.cantidadInyecciones,
    required this.totalInyectado,
    required this.cantidadRetirosCapital,
    required this.totalRetiradoCapital,
    required this.cantidadRetirosSeguro,
    required this.totalRetiradoSeguro,
    required this.cantidadPagosDobles,
    required this.cantidadPagosMenores,
    required this.faltanteTotal,
    required this.cantidadPrestamos,
    required this.totalPrestado,
    required this.cantidadReembolsos,
    required this.totalReembolsado,
  });
}

/// Préstamo nuevo asignado durante el día, con cargo a la caja. Cuando viene
/// de un reembolso (renovación de crédito), trae el id del préstamo que
/// renovó en [prestamoAnteriorId].
class PrestamoDelDiaEntity {
  final String id;
  final String clienteNombre;
  final String clienteCedula;
  final num monto;
  final num valorSeguro;
  final num valorCuota;
  final int numeroCuotas;
  final String frecuencia;
  final String estado;
  final DateTime? fecha;
  final String? prestamoAnteriorId;

  PrestamoDelDiaEntity({
    required this.id,
    required this.clienteNombre,
    required this.clienteCedula,
    required this.monto,
    required this.valorSeguro,
    required this.valorCuota,
    required this.numeroCuotas,
    required this.frecuencia,
    required this.estado,
    required this.fecha,
    this.prestamoAnteriorId,
  });

  bool get esReembolso => prestamoAnteriorId != null;
}

/// Movimiento simple de caja: inyección/retiro de capital, retiro de seguro
class InyeccionCapitalEntity {
  final String id;
  final num valor;
  final String observacion;
  final DateTime? fecha;

  InyeccionCapitalEntity({
    required this.id,
    required this.valor,
    required this.observacion,
    required this.fecha,
  });
}

/// Abono individual dentro de un pago doble o menor
class PagoMovimientoEntity {
  final String id;
  final num valor;
  final DateTime? fecha;

  PagoMovimientoEntity({
    required this.id,
    required this.valor,
    required this.fecha,
  });
}

/// Cliente que pagó más de una vez la misma cuota en el día
class PagoDobleEntity {
  final String prestamoId;
  final String clienteNombre;
  final String clienteCedula;
  final num valorCuota;
  final num valorPagado;
  final int cantidadPagos;
  final DateTime? fecha;
  final List<PagoMovimientoEntity> pagos;

  PagoDobleEntity({
    required this.prestamoId,
    required this.clienteNombre,
    required this.clienteCedula,
    required this.valorCuota,
    required this.valorPagado,
    required this.cantidadPagos,
    required this.fecha,
    required this.pagos,
  });
}

/// Pago que no alcanzó a cubrir la cuota
class PagoMenorEntity {
  final String prestamoId;
  final String clienteNombre;
  final String clienteCedula;
  final num valorCuota;
  final num valorPagado;
  final int cantidadPagos;
  final num faltante;
  final DateTime? fecha;
  final List<PagoMovimientoEntity> pagos;

  PagoMenorEntity({
    required this.prestamoId,
    required this.clienteNombre,
    required this.clienteCedula,
    required this.valorCuota,
    required this.valorPagado,
    required this.cantidadPagos,
    required this.faltante,
    required this.fecha,
    required this.pagos,
  });
}
