import 'package:personal/src/domain/entities/pago_ruta_entity.dart';

/// Datos del cliente y del préstamo, que vienen anidados en `prestamo`
Map<String, dynamic> _prestamo(Map<String, dynamic> json) =>
    (json['prestamo'] as Map<String, dynamic>?) ?? {};

String _clienteNombre(Map<String, dynamic> json) {
  final cliente =
      (_prestamo(json)['cliente'] ?? json['cliente']) as Map<String, dynamic>?;
  if (cliente == null) return '';
  return '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();
}

String _clienteCedula(Map<String, dynamic> json) {
  final cliente =
      (_prestamo(json)['cliente'] ?? json['cliente']) as Map<String, dynamic>?;
  return '${cliente?['cedula'] ?? ''}';
}

class PagoRutaModel extends PagoRutaEntity {
  PagoRutaModel({
    required super.id,
    required super.prestamoId,
    required super.valor,
    required super.estado,
    required super.fechaPago,
    required super.clienteNombre,
    required super.clienteCedula,
    required super.valorCuota,
    required super.deudaActual,
  });

  factory PagoRutaModel.fromJson(Map<String, dynamic> json) {
    final prestamo = _prestamo(json);
    return PagoRutaModel(
      id: json['id'] ?? '',
      prestamoId: json['prestamoId'] ?? '',
      valor: json['valor'] ?? 0,
      estado: json['estado'] ?? '',
      fechaPago: DateTime.tryParse('${json['fechaPago']}')?.toLocal(),
      clienteNombre: _clienteNombre(json),
      clienteCedula: _clienteCedula(json),
      valorCuota: prestamo['valorCuota'] ?? 0,
      deudaActual: prestamo['deudaActual'] ?? 0,
    );
  }
}

class NoPagoRutaModel extends NoPagoRutaEntity {
  NoPagoRutaModel({
    required super.id,
    required super.prestamoId,
    required super.motivo,
    required super.observacion,
    required super.fechaPromesa,
    required super.clienteNombre,
    required super.clienteCedula,
    required super.valorCuota,
    required super.deudaActual,
  });

  factory NoPagoRutaModel.fromJson(Map<String, dynamic> json) {
    final prestamo = _prestamo(json);
    return NoPagoRutaModel(
      id: json['id'] ?? '',
      prestamoId: json['prestamoId'] ?? '',
      motivo: json['motivo'] ?? '',
      observacion: json['observacion'] ?? '',
      // Sin toLocal: es una fecha sin hora y podría correrse de día
      fechaPromesa: DateTime.tryParse('${json['fechaPromesa']}'),
      clienteNombre: _clienteNombre(json),
      clienteCedula: _clienteCedula(json),
      valorCuota: prestamo['valorCuota'] ?? 0,
      deudaActual: prestamo['deudaActual'] ?? 0,
    );
  }
}
