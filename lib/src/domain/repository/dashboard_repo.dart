import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';

abstract class DashboardRepo {
  Future<Either<Failure, DashboardEntity>> resumen({
    required String fecha,
    required int limit,
  });

  Future<Either<Failure, ActividadPageEntity>> actividad({
    required String fecha,
    String? tipo,
    required int page,
    required int limit,
  });
}
