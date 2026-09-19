import 'package:personal/src/common/utils/date_util.dart';

/// Motivos por los que un cliente no pagó la cuota.
/// [codigo] es el valor que espera el backend.
enum MotivoNoPago {
  prometioPagar('PROMETIO_PAGAR', 'Prometió pagar'),
  noEstaba('NO_ESTABA', 'No estaba'),
  sinDinero('SIN_DINERO', 'No tenía dinero'),
  otro('OTRO', 'Otro');

  final String codigo;
  final String label;

  const MotivoNoPago(this.codigo, this.label);

  /// Solo este motivo exige una fecha de promesa
  bool get requiereFechaPromesa => this == MotivoNoPago.prometioPagar;

  /// Texto legible de un código del backend; si no se conoce, lo devuelve tal cual
  static String labelDe(String codigo) {
    for (final m in values) {
      if (m.codigo == codigo) return m.label;
    }
    return codigo;
  }
}

class NoPagoDto {
  final String prestamoId;
  final MotivoNoPago motivo;
  final String? observacion;
  final DateTime? fechaPromesa;

  NoPagoDto({
    required this.prestamoId,
    required this.motivo,
    this.observacion,
    this.fechaPromesa,
  });

  Map<String, dynamic> toJson() => {
    "prestamoId": prestamoId,
    "motivo": motivo.codigo,
    if (observacion != null && observacion!.trim().isNotEmpty)
      "observacion": observacion!.trim(),
    if (fechaPromesa != null) "fechaPromesa": DateUtil.formatDate(fechaPromesa!),
  };
}
