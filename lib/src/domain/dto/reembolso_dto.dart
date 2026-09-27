/// Renovación de crédito: de este nuevo monto, el backend descuenta
/// automáticamente la deuda actual del préstamo y el seguro; al cliente solo
/// se le entrega la diferencia (si la caja de la ruta tiene fondos).
class ReembolsoDto {
  final int monto;
  final int interes;
  final int montoInteres;
  final int numeroCuotas;
  final int valorCuota;
  final String frecuencia;
  final String fechaInicio;
  final String fechaFin;

  ReembolsoDto({
    required this.monto,
    required this.interes,
    required this.montoInteres,
    required this.numeroCuotas,
    required this.valorCuota,
    required this.frecuencia,
    required this.fechaInicio,
    required this.fechaFin,
  });

  Map<String, dynamic> toJson() => {
    'monto': monto,
    'interes': interes,
    'montoInteres': montoInteres,
    'numeroCuotas': numeroCuotas,
    'valorCuota': valorCuota,
    'frecuencia': frecuencia,
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
  };
}
