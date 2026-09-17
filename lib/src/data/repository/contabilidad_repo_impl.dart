import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/contabilidad_service.dart';
import 'package:personal/src/domain/entities/reporte_entity.dart';
import 'package:personal/src/domain/repository/contabilidad_repo.dart';

class ContabilidadRepoImpl implements ContabilidadRepo {
  final ContabilidadService contabilidadService;

  ContabilidadRepoImpl({required this.contabilidadService});

  @override
  Future<Either<Failure, ReporteCajaEntity>> obtenerCaja({
    required String cajaId,
  }) async {
    try {
      final response = await contabilidadService.obtenerCaja(cajaId: cajaId);
      return Right(response);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado: $e");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, ReporteNegocioEntity>> obtenerNegocio({
    required String fechaInicio,
    required String fechaFin,
  }) async {
    try {
      final response = await contabilidadService.obtenerNegocio(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
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
