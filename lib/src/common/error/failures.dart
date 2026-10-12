import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

//General exceptions
class ServerFailure extends Failure {
  final String? message;
  final int? statusCode;
  final String? codigo;

  const ServerFailure({
    this.message,
    this.statusCode,
    this.codigo,
  });

  @override
  List<Object?> get props => [
        message,
        statusCode,
        codigo,
      ];
}

class CacheFailure extends Failure {
  final String? message;
  final int? statusCode;

  const CacheFailure({
    this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [
        message,
        statusCode,
      ];
}