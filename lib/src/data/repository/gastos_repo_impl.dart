import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/gasto_service.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/domain/repository/gastos_repo.dart';

class GastosRepoImpl implements GastosRepo {
  final GastosService gastosService;

  GastosRepoImpl({required this.gastosService});
  @override
  Future<Either<Failure, bool>> crearGasto({required CrearGastoDto dto}) async {
    try {
      final response = await gastosService.crearGasto(dto: dto);
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, GastoEntity>> listarGastos({
    required String cajaId,
  }) async {
    try {
      final response = await gastosService.listarGastos(cajaId: cajaId);
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }
}
