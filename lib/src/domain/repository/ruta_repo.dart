import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/ruta_dto.dart';
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';
import 'package:personal/src/domain/entities/movimiento_ruta_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';

abstract class RutaRepo {
  Future<Either<Failure, dynamic>> crear({required RutaDto dto});

  Future<Either<Failure, RutasEntity>> listar();
  Future<Either<Failure, RutasEntity>> resumen({required String idsRuta});
  Future<Either<Failure, List<DetalleRutaEntity>>> detalleRuta({
    required String idRuta,
    bool esCobro = false,
  });

  Future<Either<Failure, bool>> editar({
    required String id,
    required RutaDto dto,
  });
  Future<Either<Failure, RutasEntity>> rutaCobrador();

  Future<Either<Failure, MovimientoRutaEntity>> movimiento({
    required String idRuta,
  });
}
