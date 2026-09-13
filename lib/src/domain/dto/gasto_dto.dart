class CrearGastoDto {
  final String cajaId;
  final String concepto;
  final int valor;
  final String? observacion;

  CrearGastoDto({
    required this.cajaId,
    required this.concepto,
    required this.valor,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'cajaId': cajaId,
      'concepto': concepto,
      'valor': valor,
      'observacion': observacion,
    };

    json.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );

    return json;
  }
}
