import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/prestamo_service.dart';
import 'package:personal/src/domain/dto/crear_prestamo_dto.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/domain/repository/presamo_repo.dart';

class PrestamoRepoImpl implements PresamoRepo {
  final PrestamoService prestamoService;

  PrestamoRepoImpl({required this.prestamoService});
  @override
  Future<Either<Failure, dynamic>> crear({
    required CrearPrestamoDto dto,
  }) async {
    try {
      final response = await prestamoService.crear(dto: dto);

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
  Future<Either<Failure, dynamic>> crearHistorico({
    required CrearPrestamoDto dto,
  }) async {
    try {
      final response = await prestamoService.crearHistorico(dto: dto);

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
  Future<Either<Failure, PrestamoEntity>> listar() async {
    try {
      final response = await prestamoService.listar();

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
  Future<Either<Failure, DatumPEntity>> detallePrestamo({
    required String id,
  }) async {
    try {
      final response = await prestamoService.detallePrestamo(id: id);

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
