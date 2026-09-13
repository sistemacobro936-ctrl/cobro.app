import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/auth_dto.dart';
import 'package:personal/src/domain/entities/auth_entity.dart';

abstract class AuthRepository {
    Future<Either<Failure, AuthEntity>> login({required AuthDto dto});

}