import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/administrador_dto.dart';
import 'package:personal/src/domain/dto/registro_dto.dart';
import 'package:personal/src/domain/entities/administrador_entity.dart';

abstract class NegocioRepo {
  Future<Either<Failure, dynamic>> registrar({required RegistroDto dto});

  Future<Either<Failure, dynamic>> crearAdministrador({
    required AdministradorDto dto,
  });

  Future<Either<Failure, AdministradoresEntity>> listarAdministradores();
}
