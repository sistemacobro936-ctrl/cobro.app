class RevertirPagoDto {
  final String pagoId;
  final String motivo;

  RevertirPagoDto({required this.pagoId, required this.motivo});

  Map<String, dynamic> toJson() => {
    "pagoId": pagoId,
    "motivo": motivo,
  };
}
