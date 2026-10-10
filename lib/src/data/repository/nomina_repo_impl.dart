import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/nomina_service.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/domain/repository/nomina_repo.dart';

class NominaRepoImpl implements NominaRepo {
  final NominaService nominaService;

  NominaRepoImpl({required this.nominaService});

  @override
  Future<Either<Failure, CalculoNominaEntity>> calcular({
    required String cobradorId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final response = await nominaService.calcular(
        cobradorId: cobradorId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, bool>> pagarCobrador({
    required PagoNominaCobradorDto dto,
  }) async {
    try {
      final response = await nominaService.pagarCobrador(dto: dto);
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, PagoSupervisorEntity>> pagarSupervisor({
    required PagoNominaSupervisorDto dto,
  }) async {
    try {
      final response = await nominaService.pagarSupervisor(dto: dto);
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, HistorialNominaEntity>> historial({
    required String empleadoId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await nominaService.historial(
        empleadoId: empleadoId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
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
