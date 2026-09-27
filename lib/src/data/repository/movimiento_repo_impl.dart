import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/movimiento_service.dart';
import 'package:personal/src/domain/entities/movimiento_log_entity.dart';
import 'package:personal/src/domain/repository/movimiento_repo.dart';

class MovimientoRepoImpl implements MovimientoRepo {
  final MovimientoService movimientoService;

  MovimientoRepoImpl({required this.movimientoService});

  @override
  Future<Either<Failure, MovimientoLogEntity>> listarPorRuta({
    required String rutaId,
    String? tipo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await movimientoService.listarPorRuta(
        rutaId: rutaId,
        tipo: tipo,
        page: page,
        limit: limit,
      );

      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }
}
