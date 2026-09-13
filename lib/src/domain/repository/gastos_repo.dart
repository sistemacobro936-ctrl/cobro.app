import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';

abstract class GastosRepo {
  Future<Either<Failure, bool>> crearGasto({required CrearGastoDto dto});
  Future<Either<Failure, GastoEntity>> listarGastos({required String cajaId});
}
