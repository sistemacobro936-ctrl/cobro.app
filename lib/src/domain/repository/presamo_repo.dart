import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/crear_prestamo_dto.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';

abstract class PresamoRepo {
  Future<Either<Failure, dynamic>> crear({required CrearPrestamoDto dto});
  Future<Either<Failure, dynamic>> crearHistorico({required CrearPrestamoDto dto});
  Future<Either<Failure, PrestamoEntity>> listar();
  Future<Either<Failure, DatumPEntity>> detallePrestamo({required String id});
}