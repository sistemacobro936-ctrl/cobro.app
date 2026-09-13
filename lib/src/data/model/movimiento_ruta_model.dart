import 'package:personal/src/domain/entities/movimiento_ruta_entity.dart';

class MovimientoRutaModel extends MovimientoRutaEntity {
  MovimientoRutaModel({
    required super.exito,
    required super.msg,
    required super.data,
  });

  factory MovimientoRutaModel.fromJson(Map<String, dynamic> json) =>
      MovimientoRutaModel(
        exito: json["exito"],
        msg: json["msg"],
        data: DataMovimientoM.fromJson(json["data"]),
      );
}

class DataMovimientoM extends DataMovimientoE {
  DataMovimientoM({
    required super.capital,
    required super.totalPrestado,
    required super.gananciaEsperada,
    required super.totalSeguro,
    required super.totalPrestamos,
    required super.disponible,
  });

  factory DataMovimientoM.fromJson(Map<String, dynamic> json) =>
      DataMovimientoM(
        capital: json["capital"] ?? 0,
        totalPrestado: json["totalPrestado"] ?? 0,
        gananciaEsperada: json["gananciaEsperada"] ?? 0,
        totalSeguro: json["totalSeguro"] ?? 0,
        totalPrestamos: json["totalPrestamos"] ?? 0,
        disponible: json["disponible"],
      );
}
