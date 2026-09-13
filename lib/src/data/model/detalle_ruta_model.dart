import 'package:personal/src/data/model/cliente_model.dart';
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';

class DetalleRutaModel extends DetalleRutaEntity {
  DetalleRutaModel({required super.cliente, required super.deudaActual});

  factory DetalleRutaModel.fromJson(Map<String, dynamic> json) =>
      DetalleRutaModel(
        cliente: DatumClModel.fromJson(json["cliente"]),
        deudaActual: json["deudaActual"] ?? 0,
      );
}
