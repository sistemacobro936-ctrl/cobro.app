/// Movimientos de una caja: inyecciones de capital, pagos dobles y pagos menores
class MovimientosCajaEntity {
  final MovimientosCajaInfoEntity caja;
  final ResumenMovimientosEntity resumen;
  final List<InyeccionCapitalEntity> inyeccionesCapital;
  final List<PagoDobleEntity> pagosDobles;
  final List<PagoMenorEntity> pagosMenores;

  MovimientosCajaEntity({
    required this.caja,
    required this.resumen,
    required this.inyeccionesCapital,
    required this.pagosDobles,
    required this.pagosMenores,
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
  final int cantidadPagosDobles;
  final int cantidadPagosMenores;
  final num faltanteTotal;

  ResumenMovimientosEntity({
    required this.cantidadInyecciones,
    required this.totalInyectado,
    required this.cantidadPagosDobles,
    required this.cantidadPagosMenores,
    required this.faltanteTotal,
  });
}

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
  final num valorCuota;
  final num valorPagado;
  final int cantidadPagos;
  final DateTime? fecha;
  final List<PagoMovimientoEntity> pagos;

  PagoDobleEntity({
    required this.prestamoId,
    required this.clienteNombre,
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
  final num valorCuota;
  final num valorPagado;
  final int cantidadPagos;
  final num faltante;
  final DateTime? fecha;
  final List<PagoMovimientoEntity> pagos;

  PagoMenorEntity({
    required this.prestamoId,
    required this.clienteNombre,
    required this.valorCuota,
    required this.valorPagado,
    required this.cantidadPagos,
    required this.faltante,
    required this.fecha,
    required this.pagos,
  });
}
