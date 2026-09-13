import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/ruta_service.dart';
import 'package:personal/src/domain/dto/ruta_dto.dart';
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';
import 'package:personal/src/domain/entities/movimiento_ruta_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';

class RutaRepoImpl implements RutaRepo {
  final RutaService rutaService;

  RutaRepoImpl({required this.rutaService});
  @override
  Future<Either<Failure, dynamic>> crear({required RutaDto dto}) async {
    try {
      final response = await rutaService.crear(dto: dto);

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
  Future<Either<Failure, RutasEntity>> listar() async {
    try {
      final response = await rutaService.listar();

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
  Future<Either<Failure, List<DetalleRutaEntity>>> detalleRuta({
    required String idRuta,
    bool esCobro = false,
  }) async {
    try {
      final response = await rutaService.detalleRuta(
        idRuta: idRuta,
        esCobro: esCobro,
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
  Future<Either<Failure, bool>> editar({
    required String id,
    required RutaDto dto,
  }) async {
    try {
      final response = await rutaService.editar(id: id, dto: dto);

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
  Future<Either<Failure, RutasEntity>> rutaCobrador() async {
    try {
      final response = await rutaService.rutaCobrador();

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
  Future<Either<Failure, RutasEntity>> resumen({
    required String idsRuta,
  }) async {
    try {
      final response = await rutaService.resumen(idsRuta: idsRuta);

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
  Future<Either<Failure, MovimientoRutaEntity>> movimiento({required String idRuta}) async{
    try {
      final response = await rutaService.movimiento(idRuta: idRuta);

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
