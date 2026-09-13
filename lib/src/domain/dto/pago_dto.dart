class PagoDto {
  final String prestamoId;
  final int valor;
  final DateTime fechaPago;

  PagoDto({
    required this.prestamoId,
    required this.valor,
    required this.fechaPago,
  });

  Map<String, dynamic> toJson() => {
    "prestamoId": prestamoId,
    "valor": valor,
    "fechaPago":
        "${fechaPago.year.toString().padLeft(4, '0')}-${fechaPago.month.toString().padLeft(2, '0')}-${fechaPago.day.toString().padLeft(2, '0')}",
  };
}
