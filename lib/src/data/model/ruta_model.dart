import 'package:personal/src/data/model/caja_model.dart';
import 'package:personal/src/data/model/cobrador_model.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';

class RutaModel extends RutasEntity {
  RutaModel({required super.exito, required super.msg, required super.data});

  factory RutaModel.fromJson(Map<String, dynamic> json) => RutaModel(
    exito: json["exito"],
    msg: json["msg"],
    data: List<DatumRModel>.from(
      json["data"].map((x) => DatumRModel.fromJson(x)),
    ),
  );
}

class DatumRModel extends DatumREntity {
  DatumRModel({
    required super.id,
    required super.capital,
    required super.nombre,
    required super.descripcion,
    required super.habilitada,
    super.cobrador,
    required super.cantidadClientes,
    required super.createdAt,
    required super.updatedAt,
    super.gestionRuta,
  });

  factory DatumRModel.fromJson(Map<String, dynamic> json) => DatumRModel(
    id: json["id"] ?? "",
    nombre: json["nombre"] ?? "",
    capital: json["capital"] ?? 0,
    descripcion: json["descripcion"] ?? "",
    habilitada: json["habilitada"] ?? false,
    cobrador: json["cobrador"] == null
        ? DatumCModel.fromJson({})
        : DatumCModel.fromJson(json["cobrador"]),
    cantidadClientes: json["cantidadClientes"] ?? 0,
    createdAt: DateTime.parse(
      json["createdAt"] ?? DateTime.now().toIso8601String(),
    ),
    updatedAt: DateTime.parse(
      json["updatedAt"] ?? DateTime.now().toIso8601String(),
    ),
    gestionRuta: json["gestionRuta"] == null
        ? []
        : List<DatumCajaModel>.from(
            json["gestionRuta"].map((x) => DatumCajaModel.fromJson(x)),
          ),
  );
}
