import 'package:dartz/dartz.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/data/services/solicitud_cliente_service.dart';
import 'package:personal/src/domain/dto/crear_solicitud_cliente_dto.dart';
import 'package:personal/src/domain/entities/solicitud_cliente_entity.dart';
import 'package:personal/src/domain/repository/solicitud_cliente_repo.dart';

class SolicitudClienteRepoImpl implements SolicitudClienteRepo {
  final SolicitudClienteService solicitudService;

  SolicitudClienteRepoImpl({required this.solicitudService});

  Future<Either<Failure, T>> _ejecutar<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on ServerExceptions catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Error inesperado: $e"));
    }
  }

  @override
  Future<Either<Failure, dynamic>> crear({
    required CrearSolicitudClienteDto dto,
  }) => _ejecutar(() => solicitudService.crear(dto: dto));

  @override
  Future<Either<Failure, List<SolicitudClienteEntity>>> listar({
    String? estado,
  }) => _ejecutar(() => solicitudService.listar(estado: estado));

  @override
  Future<Either<Failure, dynamic>> aprobar({required String id}) =>
      _ejecutar(() => solicitudService.aprobar(id: id));

  @override
  Future<Either<Failure, dynamic>> rechazar({
    required String id,
    String? motivo,
  }) => _ejecutar(() => solicitudService.rechazar(id: id, motivo: motivo));
}
