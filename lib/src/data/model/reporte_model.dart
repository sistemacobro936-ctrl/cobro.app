import 'package:personal/src/domain/entities/reporte_entity.dart';

class ResumenReporteModel extends ResumenReporteEntity {
  ResumenReporteModel({
    required super.base,
    super.efectivoRecibido,
    required super.cantidadRecibida,
    required super.cantidadPrestada,
    required super.esperadoACobrar,
    required super.cantidadAbonos,
    required super.cantidadPrestamos,
    required super.totalBoletas,
    required super.valorBoletas,
    required super.seguro,
    required super.gastos,
    required super.inyeccionCapital,
    required super.retiroSeguro,
    required super.utilidad,
    super.diferencia,
  });

  factory ResumenReporteModel.fromJson(Map<String, dynamic> json) =>
      ResumenReporteModel(
        base: json["base"] ?? 0,
        efectivoRecibido: json["efectivoRecibido"],
        cantidadRecibida: json["cantidadRecibida"] ?? 0,
        cantidadPrestada: json["cantidadPrestada"] ?? 0,
        esperadoACobrar: json["esperadoACobrar"] ?? 0,
        cantidadAbonos: json["cantidadAbonos"] ?? 0,
        cantidadPrestamos: json["cantidadPrestamos"] ?? 0,
        totalBoletas: json["totalBoletas"] ?? 0,
        valorBoletas: json["valorBoletas"] ?? 0,
        seguro: json["seguro"] ?? 0,
        gastos: json["gastos"] ?? 0,
        inyeccionCapital: json["inyeccionCapital"] ?? 0,
        retiroSeguro: json["retiroSeguro"] ?? 0,
        utilidad: json["utilidad"] ?? 0,
        diferencia: json["diferencia"],
      );
}

class DatumReporteCajaModel extends DatumReporteCajaEntity {
  DatumReporteCajaModel({
    required super.cajaId,
    required super.rutaId,
    required super.rutaNombre,
    required super.fechaOperacion,
    required super.estado,
    required super.base,
    super.efectivoRecibido,
    required super.cantidadRecibida,
    required super.cantidadPrestada,
    required super.esperadoACobrar,
    required super.cantidadAbonos,
    required super.cantidadPrestamos,
    required super.totalBoletas,
    required super.valorBoletas,
    required super.seguro,
    required super.gastos,
    required super.inyeccionCapital,
    required super.retiroSeguro,
    required super.utilidad,
    super.diferencia,
  });

  factory DatumReporteCajaModel.fromJson(Map<String, dynamic> json) =>
      DatumReporteCajaModel(
        cajaId: json["cajaId"] ?? "",
        rutaId: json["rutaId"] ?? "",
        rutaNombre: json["rutaNombre"] ?? "",
        fechaOperacion: DateTime.parse(
          json["fechaOperacion"] ?? DateTime.now().toIso8601String(),
        ),
        estado: json["estado"] ?? "",
        base: json["base"] ?? 0,
        efectivoRecibido: json["efectivoRecibido"],
        cantidadRecibida: json["cantidadRecibida"] ?? 0,
        cantidadPrestada: json["cantidadPrestada"] ?? 0,
        esperadoACobrar: json["esperadoACobrar"] ?? 0,
        cantidadAbonos: json["cantidadAbonos"] ?? 0,
        cantidadPrestamos: json["cantidadPrestamos"] ?? 0,
        totalBoletas: json["totalBoletas"] ?? 0,
        valorBoletas: json["valorBoletas"] ?? 0,
        seguro: json["seguro"] ?? 0,
        gastos: json["gastos"] ?? 0,
        inyeccionCapital: json["inyeccionCapital"] ?? 0,
        retiroSeguro: json["retiroSeguro"] ?? 0,
        utilidad: json["utilidad"] ?? 0,
        diferencia: json["diferencia"],
      );
}

class ReporteCajaModel extends ReporteCajaEntity {
  ReporteCajaModel({required super.exito, required super.msg, super.data});

  factory ReporteCajaModel.fromJson(Map<String, dynamic> json) =>
      ReporteCajaModel(
        exito: json["exito"] ?? false,
        msg: json["msg"] ?? "",
        data: json["data"] == null
            ? null
            : DatumReporteCajaModel.fromJson(json["data"]),
      );
}

class ReporteNegocioDataModel extends ReporteNegocioDataEntity {
  ReporteNegocioDataModel({required super.totales, required super.cajas});

  factory ReporteNegocioDataModel.fromJson(Map<String, dynamic> json) =>
      ReporteNegocioDataModel(
        totales: ResumenReporteModel.fromJson(json["totales"] ?? {}),
        cajas: json["cajas"] == null
            ? []
            : List<DatumReporteCajaModel>.from(
                json["cajas"].map((x) => DatumReporteCajaModel.fromJson(x)),
              ),
      );
}

class ReporteNegocioModel extends ReporteNegocioEntity {
  ReporteNegocioModel({required super.exito, required super.msg, super.data});

  factory ReporteNegocioModel.fromJson(Map<String, dynamic> json) =>
      ReporteNegocioModel(
        exito: json["exito"] ?? false,
        msg: json["msg"] ?? "",
        data: json["data"] == null
            ? null
            : ReporteNegocioDataModel.fromJson(json["data"]),
      );
}
