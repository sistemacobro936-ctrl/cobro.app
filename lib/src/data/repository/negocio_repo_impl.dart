import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/negocio_service.dart';
import 'package:personal/src/domain/dto/administrador_dto.dart';
import 'package:personal/src/domain/dto/registro_dto.dart';
import 'package:personal/src/domain/entities/administrador_entity.dart';
import 'package:personal/src/domain/repository/negocio_repo.dart';

class NegocioRepoImpl implements NegocioRepo {
  final NegocioService negocioService;

  NegocioRepoImpl({required this.negocioService});

  @override
  Future<Either<Failure, dynamic>> registrar({
    required RegistroDto dto,
  }) async {
    try {
      final response = await negocioService.registrar(dto: dto);
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
  Future<Either<Failure, dynamic>> crearAdministrador({
    required AdministradorDto dto,
  }) async {
    try {
      final response = await negocioService.crearAdministrador(dto: dto);
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
  Future<Either<Failure, AdministradoresEntity>>
  listarAdministradores() async {
    try {
      final response = await negocioService.listarAdministradores();
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
