/// Solicitud de un cobrador para registrar, junto con su préstamo, a alguien
/// que ya es cliente de otro negocio. La aprueba o rechaza un administrador.
class SolicitudClienteEntity {
  final String id;
  final String estado;
  final String cedula;
  final String cobradorNombre;
  final String rutaNombre;
  final String detalleOtroNegocio;
  final String? motivoRechazo;
  final DateTime? createdAt;
  final DateTime? resueltaEn;
  final SolicitudClienteDatosEntity cliente;
  final SolicitudPrestamoEntity prestamo;

  SolicitudClienteEntity({
    required this.id,
    required this.estado,
    required this.cedula,
    required this.cobradorNombre,
    required this.rutaNombre,
    required this.detalleOtroNegocio,
    required this.motivoRechazo,
    required this.createdAt,
    required this.resueltaEn,
    required this.cliente,
    required this.prestamo,
  });

  bool get pendiente => estado == 'PENDIENTE';
}

class SolicitudClienteDatosEntity {
  final String nombres;
  final String apellidos;
  final String telefono;
  final String whatsapp;
  final String direccion;
  final String descripcionDireccion;
  final String barrio;
  final String observacion;

  SolicitudClienteDatosEntity({
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.whatsapp,
    required this.direccion,
    required this.descripcionDireccion,
    required this.barrio,
    required this.observacion,
  });
}

class SolicitudPrestamoEntity {
  final num monto;
  final num valorSeguro;
  final num interes;
  final num montoInteres;
  final int numeroCuotas;
  final num valorCuota;
  final String frecuencia;
  final String fechaInicio;
  final String fechaFin;

  SolicitudPrestamoEntity({
    required this.monto,
    required this.valorSeguro,
    required this.interes,
    required this.montoInteres,
    required this.numeroCuotas,
    required this.valorCuota,
    required this.frecuencia,
    required this.fechaInicio,
    required this.fechaFin,
  });
}
