
import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/auth_service.dart';
import 'package:personal/src/domain/dto/auth_dto.dart';
import 'package:personal/src/domain/entities/auth_entity.dart';
import 'package:personal/src/domain/repository/auth_repo.dart';

class AuthRepoImpl implements AuthRepository {
  final AuthService authService;

  AuthRepoImpl({required this.authService});

  @override
  Future<Either<Failure, AuthEntity>> login({required AuthDto dto}) async {
    try {
      final resp = await authService.login(dto: dto);

      return Right(resp);
    } on ServerExceptions catch (e) {
      final failure = ServerFailure(message: e.message);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(message: "Error inesperado");
      return Left(failure);
    }
  }
}
