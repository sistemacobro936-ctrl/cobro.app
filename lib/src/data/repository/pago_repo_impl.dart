import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/pago_service.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';

class PagoRepoImpl implements PagoRepo {
  final PagoService pagoService;

  PagoRepoImpl({required this.pagoService});

  @override
  Future<Either<Failure, dynamic>> pagar({required PagoDto dto}) async {
    try {
      final response = await pagoService.pagar(dto: dto);
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, dynamic>> revertirPago({
    required String idPago,
  }) async {
    try {
      final response = await pagoService.revertirPago(idPago: idPago);
      return Right(response);
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }
}
