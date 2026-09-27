import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/domain/entities/movimiento_log_entity.dart';

class MovimientoLogModel extends MovimientoLogEntity {
  MovimientoLogModel({
    required super.exito,
    required super.msg,
    required super.data,
    super.pagination,
  });

  factory MovimientoLogModel.fromJson(Map<String, dynamic> json) =>
      MovimientoLogModel(
        exito: json["exito"] ?? false,
        msg: json["msg"] ?? "",
        pagination: json["pagination"] == null
            ? PaginationModel.fromJson({})
            : PaginationModel.fromJson(json["pagination"]),
        data: json["data"] == null
            ? <DatumMovimientoLogModel>[]
            : List<DatumMovimientoLogModel>.from(
                json["data"].map((x) => DatumMovimientoLogModel.fromJson(x)),
              ),
      );
}

class DatumMovimientoLogModel extends DatumMovimientoLogEntity {
  DatumMovimientoLogModel({
    required super.id,
    required super.negocioId,
    required super.usuarioId,
    required super.tipo,
    required super.descripcion,
    required super.referenciaId,
    required super.createdAt,
  });

  factory DatumMovimientoLogModel.fromJson(Map<String, dynamic> json) =>
      DatumMovimientoLogModel(
        id: json["id"] ?? "",
        negocioId: json["negocioId"] ?? "",
        usuarioId: json["usuarioId"] ?? "",
        tipo: json["tipo"] ?? "",
        descripcion: json["descripcion"] ?? "",
        referenciaId: json["referenciaId"] ?? "",
        createdAt:
            DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      );
}
