import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/caja_dto.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';
import 'package:personal/src/domain/entities/movimientos_caja_entity.dart';

abstract class CajaRepo {
  Future<Either<Failure, CajaEntity>> obtenerCajas({
    required String rutaId,
    required String fecha,
  });

  Future<Either<Failure, dynamic>> crearCaja({required CajaDto dto});

  Future<Either<Failure, dynamic>> cerrar({required String cajaId,required CajaDto dto});

Future<Either<Failure, CajaEntity>> historico({required String rutaID});

  Future<Either<Failure, dynamic>> inyectarCapital({
    required String cajaId,
    required int valor,
    String? observacion,
  });

  Future<Either<Failure, MovimientosCajaEntity>> movimientos({
    required String cajaId,
  });
}
