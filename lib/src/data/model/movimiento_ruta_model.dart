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
    required super.seguros,
    required super.totalPrestamos,
    required super.cartera,
    required super.disponible,
  });

  factory DataMovimientoM.fromJson(Map<String, dynamic> json) =>
      DataMovimientoM(
        capital: json["capital"] ?? 0,
        totalPrestado: json["totalPrestado"] ?? 0,
        gananciaEsperada: json["gananciaEsperada"] ?? 0,
        seguros: json["seguros"] ?? 0,
        cartera: json["cartera"] ?? 0,
        totalPrestamos: json["totalPrestamos"] ?? 0,
        disponible: json["disponible"],
      );
}
