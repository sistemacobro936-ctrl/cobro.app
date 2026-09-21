import 'package:personal/src/common/utils/date_util.dart';

class CrearGastoRutaDto {
  final String rutaId;
  final String concepto;
  final int valor;
  final String? observacion;
  final DateTime? fechaGasto;

  CrearGastoRutaDto({
    required this.rutaId,
    required this.concepto,
    required this.valor,
    this.observacion,
    this.fechaGasto,
  });

  Map<String, dynamic> toJson() => {
    'rutaId': rutaId,
    'concepto': concepto,
    'valor': valor,
    if (observacion != null && observacion!.trim().isNotEmpty)
      'observacion': observacion!.trim(),
    if (fechaGasto != null) 'fechaGasto': DateUtil.formatDate(fechaGasto!),
  };
}
