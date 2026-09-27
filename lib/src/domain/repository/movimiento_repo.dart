import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/entities/movimiento_log_entity.dart';

abstract class MovimientoRepo {
  Future<Either<Failure, MovimientoLogEntity>> listarPorRuta({
    required String rutaId,
    String? tipo,
    int page = 1,
    int limit = 20,
  });
}
