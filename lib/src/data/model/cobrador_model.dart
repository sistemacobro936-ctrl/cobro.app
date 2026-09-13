// To parse this JSON data, do
//
//     final cobradorEntity = cobradorEntityFromJson(jsonString);

import 'package:personal/src/data/model/ruta_model.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';

class CobradorModel extends CobradorEntity {
  CobradorModel({
    required super.exito,
    required super.msg,
    required super.data,
  });

  factory CobradorModel.fromJson(Map<String, dynamic> json) => CobradorModel(
    exito: json["exito"],
    msg: json["msg"],
    data: List<DatumCModel>.from(
      json["data"].map((x) => DatumCModel.fromJson(x)),
    ),
  );
}

class DatumCModel extends DatumCEntity {
  DatumCModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.documento,
    required super.telefono,
    required super.email,
    required super.estado,
    required super.rutas,
  });

  factory DatumCModel.fromJson(Map<String, dynamic> json) => DatumCModel(
    id: json["id"] ?? "",
    nombre: json["nombre"] ?? "",
    apellido: json["apellido"] ?? "",
    documento: json["documento"] ?? "",
    telefono: json["telefono"] ?? "",
    email: json["email"] ?? "",
    estado: json["estado"] ?? "",
    rutas: json["rutas"] == null
    ? []
    : List<DatumRModel>.from(
        json["rutas"].map(
          (x) => DatumRModel.fromJson(x),
        ),
      ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "apellido": apellido,
    "documento": documento,
    "telefono": telefono,
    "email": email,
    "estado": estado,
  };
}
