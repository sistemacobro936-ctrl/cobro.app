import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';
import 'package:personal/src/domain/dto/gasto_ruta_dto.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/domain/entities/gasto_ruta_entity.dart';

abstract class GastosRepo {
  Future<Either<Failure, bool>> crearGasto({required CrearGastoDto dto});
  Future<Either<Failure, GastoEntity>> listarGastos({required String cajaId});
  Future<Either<Failure, bool>> crearGastoRuta({
    required CrearGastoRutaDto dto,
  });
  Future<Either<Failure, GastosRutaEntity>> listarGastosRuta({
    required String rutaId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  });
  Future<Either<Failure, bool>> anularGastoRuta({
    required String id,
    required String motivo,
  });
}
