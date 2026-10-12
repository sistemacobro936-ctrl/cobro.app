import 'package:personal/src/domain/dto/crear_cliente_dto.dart';
import 'package:personal/src/domain/dto/crear_prestamo_dto.dart';

/// Cliente de otro negocio + el préstamo que se le quiere hacer
class CrearSolicitudClienteDto {
  final CrearClienteDto cliente;

  /// Su `clienteId` se ignora: el cliente se crea al aprobar
  final CrearPrestamoDto prestamo;

  CrearSolicitudClienteDto({required this.cliente, required this.prestamo});

  Map<String, dynamic> toJson() {
    final prestamoJson = prestamo.toJson()
      ..remove('clienteId')
      ..remove('pagos');
    final clienteJson = cliente.toJson()
      ..remove('orden')
      ..remove('agregarExistente');

    return {'cliente': clienteJson, 'prestamo': prestamoJson};
  }
}
