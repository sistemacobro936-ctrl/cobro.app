import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/dto/prestamo_fecha_dto.dart';

class CrearPrestamoDto {
  final String clienteId;
  final int monto;
  final int interes;
  final int numeroCuotas;
  final int montoInteres;
  final int valorCuota;
  final int valorSeguro;
  final String frecuencia;
  final String fechaInicio;
  final String fechaFin;
  final List<PrestamoFechaDto>? fechas;
  final List<PagoDto>? pagos;

  CrearPrestamoDto({
    required this.clienteId,
    required this.monto,
    required this.interes,
    required this.numeroCuotas,
    required this.montoInteres,
    required this.valorCuota,
    required this.frecuencia,
    required this.valorSeguro,
    required this.fechaInicio,
    required this.fechaFin,
    this.fechas,
    this.pagos,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'clienteId': clienteId,
      'monto': monto,
      'valorSeguro': valorSeguro,
      'interes': interes,
      'numeroCuotas': numeroCuotas,
      'montoInteres': montoInteres,
      'valorCuota': valorCuota,
      'frecuencia': frecuencia,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'fechas': fechas?.map((e) => e.toJson()).toList(),
      'pagos': pagos?.map((e) => e.toJson()).toList(),
    };

    json.removeWhere((key, value) => value == null);

    return json;
  }
}
