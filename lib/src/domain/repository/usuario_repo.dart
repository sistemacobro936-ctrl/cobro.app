import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/crear_cobrador_dto.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';

abstract class UsuarioRepository {
  Future<Either<Failure, CobradorEntity>> listarCobradores();

  Future<Either<Failure, DatumCEntity>> detalleCobrador({required String id});
  Future<Either<Failure, dynamic>> editarCobrador({
    required String id,
    required CrearCobradorDto dto,
  });
  Future<Either<Failure, dynamic>> crearCobrador({
    required CrearCobradorDto dto,
  });
}
