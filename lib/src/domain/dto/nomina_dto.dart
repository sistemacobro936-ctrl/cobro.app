import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';

class PagoNominaCobradorDto {
  final String rutaId;
  final String empleadoId;
  final int valor;

  /// De dónde sale: NOMINA (capital de la ruta) o SEGURO (seguros de la ruta)
  final ConceptoCalculo tipo;

  /// Texto del pago (Nómina, Prima, Seguro...); se envía como `descripcion`
  final String? concepto;
  final String? observacion;
  final DateTime? fechaPago;

  PagoNominaCobradorDto({
    required this.rutaId,
    required this.empleadoId,
    required this.valor,
    required this.tipo,
    this.concepto,
    this.observacion,
    this.fechaPago,
  });

  Map<String, dynamic> toJson() => {
    "rutaId": rutaId,
    "empleadoId": empleadoId,
    "valor": valor,
    "concepto": tipo.api,
    if (concepto != null && concepto!.isNotEmpty) "descripcion": concepto,
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

  /// De dónde sale cada reparto: NOMINA (capital) o SEGURO (seguros)
  final ConceptoCalculo tipo;

  /// Texto del pago; se envía como `descripcion`
  final String? concepto;
  final String? observacion;
  final DateTime? fechaPago;

  PagoNominaSupervisorDto({
    required this.empleadoId,
    required this.repartos,
    required this.tipo,
    this.concepto,
    this.observacion,
    this.fechaPago,
  });

  Map<String, dynamic> toJson() => {
    "empleadoId": empleadoId,
    "repartos": repartos.map((r) => r.toJson()).toList(),
    "concepto": tipo.api,
    if (concepto != null && concepto!.isNotEmpty) "descripcion": concepto,
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
