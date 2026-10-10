import 'package:personal/src/common/utils/date_util.dart';

class PagoNominaCobradorDto {
  final String rutaId;
  final String empleadoId;
  final int valor;
  final String? concepto;
  final String? observacion;
  final DateTime? fechaPago;

  PagoNominaCobradorDto({
    required this.rutaId,
    required this.empleadoId,
    required this.valor,
    this.concepto,
    this.observacion,
    this.fechaPago,
  });

  Map<String, dynamic> toJson() => {
    "rutaId": rutaId,
    "empleadoId": empleadoId,
    "valor": valor,
    if (concepto != null && concepto!.isNotEmpty) "concepto": concepto,
    if (observacion != null && observacion!.isNotEmpty)
      "observacion": observacion,
    if (fechaPago != null) "fechaPago": DateUtil.formatDate(fechaPago!),
  };
}

class RepartoNominaDto {
  final String rutaId;
  final int valor;

  RepartoNominaDto({required this.rutaId, required this.valor});

  Map<String, dynamic> toJson() => {"rutaId": rutaId, "valor": valor};
}

class PagoNominaSupervisorDto {
  final String empleadoId;
  final List<RepartoNominaDto> repartos;
  final String? concepto;
  final String? observacion;
  final DateTime? fechaPago;

  PagoNominaSupervisorDto({
    required this.empleadoId,
    required this.repartos,
    this.concepto,
    this.observacion,
    this.fechaPago,
  });

  Map<String, dynamic> toJson() => {
    "empleadoId": empleadoId,
    "repartos": repartos.map((r) => r.toJson()).toList(),
    if (concepto != null && concepto!.isNotEmpty) "concepto": concepto,
    if (observacion != null && observacion!.isNotEmpty)
      "observacion": observacion,
    if (fechaPago != null) "fechaPago": DateUtil.formatDate(fechaPago!),
  };
}

/// % de la boleta del cobrador (entero de 0 a 100)
class ComisionDto {
  final int comisionPorcentaje;

  ComisionDto({required this.comisionPorcentaje});

  Map<String, dynamic> toJson() => {"comisionPorcentaje": comisionPorcentaje};
}
