class CajaDto {
  final String rutaId;
  final int montoInicial;
  final String fechaApertura;

  CajaDto({
    required this.rutaId,
    required this.montoInicial,
    required this.fechaApertura,
  });
  Map<String, dynamic> tojson() => {
    "rutaId": rutaId,
    "montoInicial": montoInicial,
    "fechaApertura": fechaApertura,
  };
}
