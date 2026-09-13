import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/config_dto.dart';
import 'package:personal/src/domain/entities/config_entity.dart';

abstract class ConfiguracionRepository {
  Future<Either<Failure, ConfigEntity>> obtenerConfiguracion();

  Future<Either<Failure, dynamic>> guardarConfiguracion({
    required ConfigDto dto,
  });
}
