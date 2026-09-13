import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/cliente_service.dart';
import 'package:personal/src/domain/dto/crear_cliente_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';

class ClienteRepoImpl implements ClienteRepository {
  final ClienteService clienteService;

  ClienteRepoImpl({required this.clienteService});

  @override
  Future<Either<Failure, ClienteEntity>> listar() async {
    try {
      final response = await clienteService.listar();

      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, String>> crear({required CrearClienteDto dto}) async {
    try {
      final response = await clienteService.crear(dto: dto);

      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, DatumClEntity>> obtenerCliente({
    required String id,
  }) async {
    try {
      final response = await clienteService.obtenerCliente(id: id);

      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, dynamic>> editar({
    required CrearClienteDto dto,
    required String id,
  }) async {
    try {
      final response = await clienteService.editar(dto: dto, id: id);
      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, ClienteEntity>> buscar({required String q}) async {
    try {
      final response = await clienteService.buscar(q: q);
      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, ClienteEntity>> clientesPorRuta({
    required String idRuta,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await clienteService.clientesPorRuta(
        idRuta: idRuta,
        page: page,
        limit: limit,
      );
      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }
}
