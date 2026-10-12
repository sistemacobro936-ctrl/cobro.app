import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/mora_service.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';
import 'package:personal/src/domain/repository/mora_repo.dart';

class MoraRepoImpl implements MoraRepo {
  final MoraService moraService;

  MoraRepoImpl({required this.moraService});

  Future<Either<Failure, T>> _ejecutar<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, List<RangoMoraEntity>>> rangos() =>
      _ejecutar(moraService.rangos);

  @override
  Future<Either<Failure, List<RangoMoraEntity>>> guardarRangos(
    List<RangoMoraEntity> rangos,
  ) => _ejecutar(() => moraService.guardarRangos(rangos));

  @override
  Future<Either<Failure, AtrasadosPageEntity>> atrasados({
    int? nivel,
    String? estadoCliente,
    int page = 1,
    int limit = 20,
  }) => _ejecutar(
    () => moraService.atrasados(
      nivel: nivel,
      estadoCliente: estadoCliente,
      page: page,
      limit: limit,
    ),
  );
}
