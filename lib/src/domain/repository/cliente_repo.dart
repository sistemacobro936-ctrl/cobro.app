import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/crear_cliente_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';

abstract class ClienteRepository {
  Future<Either<Failure, ClienteEntity>> listar();
  Future<Either<Failure, ClienteEntity>> clientesPorRuta({required String idRuta, int page=1, int limit=10});
  Future<Either<Failure, ClienteEntity>> buscar({required String q});

  Future<Either<Failure, String>> crear({required CrearClienteDto dto});
  Future<Either<Failure, dynamic>> editar({required CrearClienteDto dto, required String id});
  Future<Either<Failure, DatumClEntity>> obtenerCliente({required String id});
}
