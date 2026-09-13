import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/data/model/prestamo_model.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';

class ClienteModel extends ClienteEntity {
  ClienteModel({required super.exito, required super.msg, required super.data, super.pagination});

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
    exito: json["exito"],
    msg: json["msg"],
        pagination: json["pagination"] == null
        ? PaginationModel.fromJson({})
        : PaginationModel.fromJson(json["pagination"]),
    data: List<DatumClModel>.from(
      json["data"].map((x) => DatumClModel.fromJson(x)),
    ),
  );
}

class DatumClModel extends DatumClEntity {
  DatumClModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.rutaId,
    required super.cedula,
    required super.whatsapp,
    required super.direccion,
    required super.descripcionDireccion,
    required super.barrio,
    required super.observacion,
    required super.estado,
    required super.totalPrestado,
    super.prestamos,
  });

  factory DatumClModel.fromJson(Map<String, dynamic> json) => DatumClModel(
    id: json["id"] ?? "",
    nombres: json["nombres"] ?? "",
    apellidos: json["apellidos"] ?? "",
    cedula: json["cedula"] ?? "",
    telefono: json["telefono"] ?? "",
    rutaId: json["rutaId"] ?? "",
    whatsapp: json["whatsapp"] ?? "",
    direccion: json["direccion"] ?? "",
    observacion: json["observacion"] ?? "",
    barrio: json["barrio"] ?? "",
    descripcionDireccion: json["descripcionDireccion"] ?? "",
    estado: json["estado"] ?? "",
    totalPrestado: json["totalPrestado"] ?? 0,

    prestamos: json["prestamos"] == null
        ? <DatumPModel>[]
        : (json["prestamos"] as List)
              .map((e) => DatumPModel.fromJson(e))
              .toList(),
  );
}
