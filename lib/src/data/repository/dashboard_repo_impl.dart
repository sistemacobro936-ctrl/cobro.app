import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/dashboard_service.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';
import 'package:personal/src/domain/repository/dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  final DashboardService dashboardService;

  DashboardRepoImpl({required this.dashboardService});

  @override
  Future<Either<Failure, DashboardEntity>> resumen({
    required String fecha,
    required int limit,
  }) async {
    try {
      final response = await dashboardService.resumen(
        fecha: fecha,
        limit: limit,
      );
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, ActividadPageEntity>> actividad({
    required String fecha,
    String? tipo,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await dashboardService.actividad(
        fecha: fecha,
        tipo: tipo,
        page: page,
        limit: limit,
      );
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }
}
