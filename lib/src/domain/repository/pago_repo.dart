import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';

abstract class PagoRepo {
  Future<Either<Failure, dynamic>> pagar({required PagoDto dto});
  Future<Either<Failure, dynamic>> revertirPago({required String idPago});
}