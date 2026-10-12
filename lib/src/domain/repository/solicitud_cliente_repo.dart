import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/domain/dto/crear_solicitud_cliente_dto.dart';
import 'package:personal/src/domain/entities/solicitud_cliente_entity.dart';

abstract class SolicitudClienteRepo {
  Future<Either<Failure, dynamic>> crear({required CrearSolicitudClienteDto dto});
  Future<Either<Failure, List<SolicitudClienteEntity>>> listar({String? estado});
  Future<Either<Failure, dynamic>> aprobar({required String id});
  Future<Either<Failure, dynamic>> rechazar({required String id, String? motivo});
}
