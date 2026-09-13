// domain/entities/cuota_esperada_entity.dart

class CuotaEsperada {
  final int numero;
  final DateTime fechaCobro;
  final bool esPasada;
  double monto;

  CuotaEsperada({
    required this.numero,
    required this.fechaCobro,
    required this.esPasada,
    required this.monto,
  });
}