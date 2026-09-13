// To parse super JSON data, do
//
//     final gastoModel = gastoModelFromJson(jsonString);

import 'package:personal/src/domain/entities/gasto_entity.dart';

class GastoModel extends GastoEntity {
  GastoModel({required super.exito, required super.msg, required super.data});

  factory GastoModel.fromJson(Map<String, dynamic> json) => GastoModel(
    exito: json["exito"],
    msg: json["msg"],
    data: DataGastoModel.fromJson(json["data"]),
  );
}

class DataGastoModel extends DataGastoEntity {
  DataGastoModel({required super.gastos});

  factory DataGastoModel.fromJson(Map<String, dynamic> json) => DataGastoModel(
    gastos: List<GastoElementModel>.from(
      json["gastos"].map((x) => GastoElementModel.fromJson(x)),
    ),
  );
}

class GastoElementModel extends GastoElementEntity {
  GastoElementModel({
    required super.id,
    required super.cajaId,
    required super.concepto,
    required super.valor,
    required super.observacion,
    required super.fecha,
  });

  factory GastoElementModel.fromJson(Map<String, dynamic> json) =>
      GastoElementModel(
        id: json["id"],
        cajaId: json["cajaId"],
        concepto: json["concepto"],
        valor: json["valor"],
        observacion: json["observacion"],
        fecha: DateTime.parse(json["fecha"]),
      );
}
