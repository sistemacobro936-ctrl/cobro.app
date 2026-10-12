import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';

abstract class MoraRepo {
  Future<Either<Failure, List<RangoMoraEntity>>> rangos();
  Future<Either<Failure, List<RangoMoraEntity>>> guardarRangos(
    List<RangoMoraEntity> rangos,
  );
  Future<Either<Failure, AtrasadosPageEntity>> atrasados({
    int? nivel,
    String? estadoCliente,
    int page = 1,
    int limit = 20,
  });
}
