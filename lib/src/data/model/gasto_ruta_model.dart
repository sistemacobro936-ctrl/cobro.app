import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/domain/entities/gasto_ruta_entity.dart';

class GastoRutaModel extends GastoRutaEntity {
  GastoRutaModel({
    required super.id,
    required super.rutaId,
    required super.concepto,
    required super.valor,
    required super.observacion,
    required super.fechaGasto,
    required super.estado,
    required super.registradoPorNombre,
    required super.motivoAnulacion,
  });

  factory GastoRutaModel.fromJson(Map<String, dynamic> json) => GastoRutaModel(
    id: json['id'] ?? '',
    rutaId: json['rutaId'] ?? '',
    concepto: json['concepto'] ?? '',
    valor: json['valor'] ?? 0,
    observacion: json['observacion'] ?? '',
    // Sin toLocal: es una fecha sin hora y podría correrse de día
    fechaGasto: DateTime.tryParse('${json['fechaGasto']}'),
    estado: json['estado'] ?? 'ACTIVO',
    registradoPorNombre: json['registradoPorNombre'] ?? '',
    motivoAnulacion: json['motivoAnulacion'] ?? '',
  );
}

class GastosRutaModel extends GastosRutaEntity {
  GastosRutaModel({
    required super.resumen,
    required super.gastos,
    required super.pagination,
  });

  /// Recibe la respuesta completa `{ exito, msg, data: { resumen, gastos }, pagination }`
  factory GastosRutaModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final resumen = (data['resumen'] as Map<String, dynamic>?) ?? {};

    return GastosRutaModel(
      resumen: ResumenGastosRutaEntity(
        cantidad: resumen['cantidad'] ?? 0,
        total: resumen['total'] ?? 0,
      ),
      gastos: List<GastoRutaEntity>.from(
        ((data['gastos'] as List?) ?? []).map((x) => GastoRutaModel.fromJson(x)),
      ),
      pagination: PaginationModel.fromJson(
        (json['pagination'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
