import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/entities/reporte_entity.dart';

abstract class ContabilidadRepo {
  Future<Either<Failure, ReporteCajaEntity>> obtenerCaja({
    required String cajaId,
  });

  Future<Either<Failure, ReporteNegocioEntity>> obtenerNegocio({
    required String fechaInicio,
    required String fechaFin,
  });
}
