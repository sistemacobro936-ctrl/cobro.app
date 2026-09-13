class PrestamoFechaDto{
  final int numero;
  final String fechaPago;
  final int valor;

  PrestamoFechaDto({
    required this.numero,
    required this.fechaPago,
    required this.valor,
  });

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'fechaPago': fechaPago,
      'valor': valor,
    };
  }
}