import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/caja_service.dart';
import 'package:personal/src/domain/dto/caja_dto.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';
import 'package:personal/src/domain/repository/caja_repo.dart';

class CajaRepoImpl implements CajaRepo {
  final CajaService cajaService;

  CajaRepoImpl({required this.cajaService});
  @override
  Future<Either<Failure, CajaEntity>> obtenerCajas({
    required String rutaId,
    required String fecha,
  }) async {
    try {
      final response = await cajaService.obtenerCajas(
        rutaId: rutaId,
        fecha: fecha,
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

  @override
  Future<Either<Failure, dynamic>> crearCaja({required CajaDto dto}) async {
    try {
      final response = await cajaService.crearCaja(dto: dto);
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
  Future<Either<Failure, CajaEntity>> historico({
    required String rutaID,
  }) async {
    try {
      final response = await cajaService.historico(rutaID: rutaID);
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
  Future<Either<Failure, dynamic>> cerrar({
    required String cajaId,
    required CajaDto dto,
  }) async {
    try {
      final response = await cajaService.cerrar(cajaId: cajaId, dto: dto);
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
