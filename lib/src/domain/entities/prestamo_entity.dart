import 'package:personal/src/data/model/cliente_model.dart';
import 'package:personal/src/domain/entities/pago_entity.dart';

class PrestamoEntity {
  final bool exito;
  final String msg;
  final List<DatumPEntity> data;

  PrestamoEntity({required this.exito, required this.msg, required this.data});
}

class DatumPEntity {
  final String id;
  final String usuarioId;
  final String creadoPorId;
  final int monto;
  final int valorCuota;
  final int interes;
  final int montoInteres;
  final int totalPagar;
  final int numeroCuotas;
  final int deudaActual;
  final String frecuencia;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DatumClModel cliente;
  final bool? yaPago;
  final List<FechasPagoPEntity> fechasPago;
final List<PagoEntity> pagos;

  DatumPEntity({
    required this.id,
    required this.usuarioId,
    required this.creadoPorId,
    required this.monto,
    required this.valorCuota,
    required this.interes,
    required this.montoInteres,
    required this.totalPagar,
    required this.numeroCuotas,
    required this.frecuencia,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.fechasPago,
    required this.cliente,
    required this.deudaActual,
    required this.pagos,
    this.yaPago
  });
}

enum Estado { ACTIVO }

class FechasPagoPEntity {
  final String id;
  final String prestamoId;
  final int numero;
  final DateTime fechaPago;
  final int valor;
  final DateTime createdAt;

  FechasPagoPEntity({
    required this.id,
    required this.prestamoId,
    required this.numero,
    required this.fechaPago,
    required this.valor,
    required this.createdAt,
  });
}

enum Frecuencia { DIARIO, SEMANAL }
