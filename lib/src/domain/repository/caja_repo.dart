import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/caja_dto.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';

abstract class CajaRepo {
  Future<Either<Failure, CajaEntity>> obtenerCajas({
    required String rutaId,
    required String fecha,
  });

  Future<Either<Failure, dynamic>> crearCaja({required CajaDto dto});

Future<Either<Failure, CajaEntity>> historico({required String rutaID});
}
