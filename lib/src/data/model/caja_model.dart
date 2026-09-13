// To parse super JSON data, do
//
//     final cajaModel = cajaModelFromJson(jsonString);

import 'package:personal/src/data/model/gasto_model.dart';
import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/data/model/pago_model.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';

class CajaModel extends CajaEntity {
  CajaModel({required super.exito, required super.msg, required super.data});

  factory CajaModel.fromJson(Map<String, dynamic> json) => CajaModel(
    exito: json["exito"],
    msg: json["msg"],
    data: json["data"] == null
        ? []
        : List<DatumCajaModel>.from(json["data"].map((x) => DatumCajaModel.fromJson(x))),
  );
}

class DatumCajaModel extends DatumCajaEntity {
  DatumCajaModel({
    required super.id,
    required super.rutaId,
    required super.abiertaPorId,
    required super.montoInicial,
    required super.montoEsperado,
    required super.cobroEsperado,
    required super.montoReal,
    required super.diferencia,
    required super.estado,
    required super.fechaApertura,
    required super.fechaCierre,
    required super.createdAt,
    required super.updatedAt,
    required super.montoPrestado,
    required super.fechaOperacion,
    required super.gastos,
    required super.cobrado,
    required super.interesGenerado,
    required super.saldoSeguros,
    super.pagos,
    super.gastosCaja,
    super.pagination,
    super.observacion,
  });

  factory DatumCajaModel.fromJson(Map<String, dynamic> json) => DatumCajaModel(
    id: json["id"] ?? "",
    rutaId: json["rutaId"] ?? "",
    observacion: json["observacion"] ?? "",
    abiertaPorId: json["abiertaPorId"] ?? "",
    cobroEsperado: json["cobroEsperado"] ?? 0,
    montoInicial: json["montoInicial"] ?? 0,
    interesGenerado: json["interesGenerado"] ?? 0,
    saldoSeguros: json["saldoSeguros"] ?? 0,
    cobrado: json["cobrado"] ?? 0,
    gastos: json["gastos"] ?? 0,
    montoEsperado: json["montoEsperado"] ?? 0,
    montoReal: json["montoReal"] ?? 0,
    diferencia: json["diferencia"] ?? 0,
    montoPrestado: json["montoPrestado"] ?? 0,
    estado: json["estado"] ?? "",
    fechaApertura: DateTime.parse(
      json["fechaApertura"] ?? DateTime.now().toIso8601String(),
    ),
    fechaCierre: json["fechaCierre"],
    createdAt: DateTime.parse(
      json["createdAt"] ?? DateTime.now().toIso8601String(),
    ),
    updatedAt: DateTime.parse(
      json["updatedAt"] ?? DateTime.now().toIso8601String(),
    ),
    fechaOperacion: DateTime.parse(
      json["fechaOperacion"] ?? DateTime.now().toIso8601String(),
    ),
    pagos: json["pagos"] == null
        ? []
        : List<PagoModel>.from(json["pagos"].map((x) => PagoModel.fromJson(x))),
    gastosCaja: json["gastosCaja"] == null
        ? []
        : List<GastoElementModel>.from(
            json["gastosCaja"].map((x) => GastoElementModel.fromJson(x)),
          ),
    pagination: json["pagination"] == null
        ? PaginationModel.fromJson({})
        : PaginationModel.fromJson(json["pagination"]),
  );
}
