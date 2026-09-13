import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/usuario_service.dart';
import 'package:personal/src/domain/dto/crear_cobrador_dto.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';
import 'package:personal/src/domain/repository/usuario_repo.dart';

class UsuarioRepoImpl implements UsuarioRepository {
  final UsuarioService usuarioService;

  UsuarioRepoImpl({required this.usuarioService});

  @override
  Future<Either<Failure, CobradorEntity>> listarCobradores() async {
    try {
      final response = await usuarioService.listarCobradores();

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
  Future<Either<Failure, dynamic>> crearCobrador({
    required CrearCobradorDto dto,
  }) async {
    try {
      final response = await usuarioService.crearCobrador(dto: dto);

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
  Future<Either<Failure, DatumCEntity>> detalleCobrador({
    required String id,
  }) async {
    try {
      final response = await usuarioService.detalleCobrador(id: id);

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
  Future<Either<Failure, dynamic>> editarCobrador({
    required String id,
    required CrearCobradorDto dto,
  }) async {
    try {
      final response = await usuarioService.editarCobrador(id: id, dto: dto);

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
