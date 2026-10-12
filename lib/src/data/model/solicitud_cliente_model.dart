import 'package:personal/src/domain/entities/solicitud_cliente_entity.dart';

class SolicitudClienteModel extends SolicitudClienteEntity {
  SolicitudClienteModel({
    required super.id,
    required super.estado,
    required super.cedula,
    required super.cobradorNombre,
    required super.rutaNombre,
    required super.detalleOtroNegocio,
    required super.motivoRechazo,
    required super.createdAt,
    required super.resueltaEn,
    required super.cliente,
    required super.prestamo,
  });

  factory SolicitudClienteModel.fromJson(Map<String, dynamic> json) {
    final c = (json['cliente'] as Map<String, dynamic>?) ?? {};
    final p = (json['prestamo'] as Map<String, dynamic>?) ?? {};

    return SolicitudClienteModel(
      id: json['id'] ?? '',
      estado: json['estado'] ?? '',
      cedula: json['cedula'] ?? '',
      cobradorNombre: json['cobradorNombre'] ?? '',
      rutaNombre: json['rutaNombre'] ?? '',
      detalleOtroNegocio: json['detalleOtroNegocio'] ?? '',
      motivoRechazo: json['motivoRechazo'],
      createdAt: DateTime.tryParse('${json['createdAt']}')?.toLocal(),
      resueltaEn: DateTime.tryParse('${json['resueltaEn']}')?.toLocal(),
      cliente: SolicitudClienteDatosEntity(
        nombres: c['nombres'] ?? '',
        apellidos: c['apellidos'] ?? '',
        telefono: c['telefono'] ?? '',
        whatsapp: c['whatsapp'] ?? '',
        direccion: c['direccion'] ?? '',
        descripcionDireccion: c['descripcionDireccion'] ?? '',
        barrio: c['barrio'] ?? '',
        observacion: c['observacion'] ?? '',
      ),
      prestamo: SolicitudPrestamoEntity(
        monto: p['monto'] ?? 0,
        valorSeguro: p['valorSeguro'] ?? 0,
        interes: p['interes'] ?? 0,
        montoInteres: p['montoInteres'] ?? 0,
        numeroCuotas: p['numeroCuotas'] ?? 0,
        valorCuota: p['valorCuota'] ?? 0,
        frecuencia: p['frecuencia'] ?? '',
        fechaInicio: '${p['fechaInicio'] ?? ''}',
        fechaFin: '${p['fechaFin'] ?? ''}',
      ),
    );
  }
}
