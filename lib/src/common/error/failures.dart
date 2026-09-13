import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

//General exceptions
class ServerFailure extends Failure {
  final String? message;
  final int? statusCode;

  const ServerFailure({
    this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [
        message,
        statusCode,
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