import 'package:personal/src/data/model/cliente_model.dart';
import 'package:personal/src/data/model/pago_model.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';

class PrestamoModel extends PrestamoEntity {
  PrestamoModel({
    required super.exito,
    required super.msg,
    required super.data,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) => PrestamoModel(
    exito: json["exito"],
    msg: json["msg"],
    data: List<DatumPModel>.from(
      json["data"].map((x) => DatumPModel.fromJson(x)),
    ),
  );
}

class DatumPModel extends DatumPEntity {
  DatumPModel({
    required super.id,
    required super.usuarioId,
    required super.creadoPorId,
    required super.monto,
    required super.valorCuota,
    required super.interes,
    required super.montoInteres,
    required super.deudaActual,
    required super.totalPagar,
    required super.numeroCuotas,
    required super.frecuencia,
    required super.fechaInicio,
    required super.fechaFin,
    required super.estado,
    required super.createdAt,
    required super.updatedAt,
    required super.fechasPago,
    required super.cliente,
    required super.pagos,
    super.yaPago
  });

  factory DatumPModel.fromJson(Map<String, dynamic> json) => DatumPModel(
    id: json["id"],
    usuarioId: json["clienteId"] ??"",
    deudaActual: json["deudaActual"] ?? 0,
    creadoPorId: json["creadoPorId"] ??"",
    monto: json["monto"] ??0,
    valorCuota: json["valorCuota"] ?? 0,
    interes: json["interes"] ?? 0,
    montoInteres: json["montoInteres"] ?? 0,
    totalPagar: json["totalPagar"]?? 0,
    numeroCuotas: json["numeroCuotas"]?? 0,
    yaPago: json["yaPago"]?? false,
    frecuencia: json["frecuencia"] ??"",
    cliente: json["cliente"] == null
        ? DatumClModel.fromJson({})
        : DatumClModel.fromJson(json["cliente"]),
    fechaInicio: DateTime.parse(json["fechaInicio"] ?? DateTime.now().toIso8601String()) ,
    fechaFin: DateTime.parse(json["fechaFin"]??  DateTime.now().toIso8601String()),
    estado: json["estado"]??"",
    createdAt: DateTime.parse(json["createdAt"]??  DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json["updatedAt"]??  DateTime.now().toIso8601String()),
    fechasPago: json["fechasPago"] == null
        ? []
        : List<FechasPagoPModel>.from(
            json["fechasPago"].map((x) => FechasPagoPModel.fromJson(x)),
          ),
    pagos: json["pagos"] == null
        ? []
        : List<PagoModel>.from(json["pagos"].map((x) => PagoModel.fromJson(x))),
  );
}

class FechasPagoPModel extends FechasPagoPEntity {
  FechasPagoPModel({
    required super.id,
    required super.prestamoId,
    required super.numero,
    required super.fechaPago,
    required super.valor,
    required super.createdAt,
  });

  factory FechasPagoPModel.fromJson(Map<String, dynamic> json) =>
      FechasPagoPModel(
        id: json["id"],
        prestamoId: json["prestamoId"],
        numero: json["numero"],
        fechaPago: DateTime.parse(json["fechaPago"]),
        valor: json["valor"],
        createdAt: DateTime.parse(json["createdAt"]),
      );
}
