import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';

class PagoNominaCobradorDto {
  final String rutaId;
  final String empleadoId;
  final int valor;
  final String? concepto;
  final String? observacion;
  final DateTime? fechaGasto;

  PagoNominaCobradorDto({
    required this.rutaId,
    required this.empleadoId,
    required this.valor,
    this.concepto,
    this.observacion,
    this.fechaGasto,
  });

  Map<String, dynamic> toJson() => {
    "rutaId": rutaId,
    "empleadoId": empleadoId,
    "valor": valor,
    if (concepto != null && concepto!.isNotEmpty) "concepto": concepto,
    if (observacion != null && observacion!.isNotEmpty)
      "observacion": observacion,
    if (fechaGasto != null) "fechaGasto": DateUtil.formatDate(fechaGasto!),
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
  final DateTime? fechaGasto;

  PagoNominaSupervisorDto({
    required this.empleadoId,
    required this.repartos,
    this.concepto,
    this.observacion,
    this.fechaGasto,
  });

  Map<String, dynamic> toJson() => {
    "empleadoId": empleadoId,
    "repartos": repartos.map((r) => r.toJson()).toList(),
    if (concepto != null && concepto!.isNotEmpty) "concepto": concepto,
    if (observacion != null && observacion!.isNotEmpty)
      "observacion": observacion,
    if (fechaGasto != null) "fechaGasto": DateUtil.formatDate(fechaGasto!),
  };
}

/// Comisión de un usuario. Se envían ambos campos; null los deja sin configurar
class ComisionDto {
  final ComisionBase? comisionBase;
  final num? comisionPorcentaje;

  ComisionDto({required this.comisionBase, required this.comisionPorcentaje});

  Map<String, dynamic> toJson() => {
    "comisionBase": comisionBase?.api,
    "comisionPorcentaje": comisionPorcentaje,
  };
}
