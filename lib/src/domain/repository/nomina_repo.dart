import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';

abstract class NominaRepo {
  Future<Either<Failure, CalculoNominaEntity>> calcular({
    required String cobradorId,
    String? fechaInicio,
    String? fechaFin,
  });

  Future<Either<Failure, bool>> pagarCobrador({
    required PagoNominaCobradorDto dto,
  });

  Future<Either<Failure, PagoSupervisorEntity>> pagarSupervisor({
    required PagoNominaSupervisorDto dto,
  });

  Future<Either<Failure, HistorialNominaEntity>> historial({
    required String empleadoId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  });
}
