import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/entities/pago_ruta_entity.dart';

abstract class PagoRepo {
  Future<Either<Failure, dynamic>> pagar({required PagoDto dto});
  Future<Either<Failure, dynamic>> noPago({required NoPagoDto dto});
  Future<Either<Failure, List<PagoRutaEntity>>> pagosRuta({
    required String rutaId,
    required String fecha,
  });
  Future<Either<Failure, List<NoPagoRutaEntity>>> noPagosRuta({
    required String rutaId,
    required String fecha,
  });
  Future<Either<Failure, dynamic>> revertirPago({required String idPago});
}