import 'package:personal/src/domain/entities/pago_entity.dart';

class PagoModel extends PagoEntity {
  PagoModel({
    required super.id,
    required super.prestamoId,
    required super.registradoPorId,
    required super.valor,
    required super.estado,
    super.fechaReversion,
    super.fechaPago,
    super.usuarioReversionId,
    super.motivoReversion,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id'] ?? '',
      prestamoId: json['prestamoId'] ?? '',
      registradoPorId: json['registradoPorId'] ?? '',
      valor: json['valor'] ?? 0,
      estado: json['estado'] ?? '',
      fechaReversion: json['fechaReversion'] != null
          ? DateTime.tryParse(json['fechaReversion'].toString())
          : null,
      fechaPago: json['fechaPago'] != null
          ? DateTime.tryParse(json['fechaPago'].toString())
          : null,
      usuarioReversionId: json['usuarioReversionId'],
      motivoReversion: json['motivoReversion'],
      createdAt: DateTime.parse(json['createdAt']?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?? DateTime.now().toIso8601String()),
    );
  }
  bool get aplicado => estado == 'APLICADO';

  bool get reversado => estado == 'REVERSADO';
}
