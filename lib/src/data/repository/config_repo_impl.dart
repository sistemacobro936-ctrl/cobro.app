import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/config_service.dart';
import 'package:personal/src/domain/dto/config_dto.dart';
import 'package:personal/src/domain/entities/config_entity.dart';
import 'package:personal/src/domain/repository/config_repo.dart';

class ConfiguracionRepoImpl implements ConfiguracionRepository {
  final ConfiguracionService configuracionService;

  ConfiguracionRepoImpl({required this.configuracionService});

  @override
  Future<Either<Failure, ConfigEntity>> obtenerConfiguracion() async {
    try {
      final response = await configuracionService.obtenerConfiguracion();

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
  Future<Either<Failure, dynamic>> guardarConfiguracion({
    required ConfigDto dto,
  }) async {
    try {
      final response = await configuracionService.guardarConfiguracion(
        dto: dto,
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
