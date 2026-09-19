/// Pago registrado en una ruta en una fecha de operación
class PagoRutaEntity {
  final String id;
  final String prestamoId;
  final num valor;
  final String estado;
  final DateTime? fechaPago;
  final String clienteNombre;
  final String clienteCedula;
  final num valorCuota;
  final num deudaActual;

  PagoRutaEntity({
    required this.id,
    required this.prestamoId,
    required this.valor,
    required this.estado,
    required this.fechaPago,
    required this.clienteNombre,
    required this.clienteCedula,
    required this.valorCuota,
    required this.deudaActual,
  });

  bool get aplicado => estado == 'APLICADO';
}

/// Cuota que el cliente no pagó en una ruta en una fecha de operación
class NoPagoRutaEntity {
  final String id;
  final String prestamoId;
  final String motivo;
  final String observacion;
  final DateTime? fechaPromesa;
  final String clienteNombre;
  final String clienteCedula;
  final num valorCuota;
  final num deudaActual;

  NoPagoRutaEntity({
    required this.id,
    required this.prestamoId,
    required this.motivo,
    required this.observacion,
    required this.fechaPromesa,
    required this.clienteNombre,
    required this.clienteCedula,
    required this.valorCuota,
    required this.deudaActual,
  });
}
