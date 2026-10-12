import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/solicitud_cliente_model.dart';
import 'package:personal/src/domain/dto/crear_solicitud_cliente_dto.dart';

abstract class SolicitudClienteService {
  Future<dynamic> crear({required CrearSolicitudClienteDto dto});

  /// [estado]: PENDIENTE, APROBADA o RECHAZADA; null = todas. El cobrador
  /// solo recibe las suyas.
  Future<List<SolicitudClienteModel>> listar({String? estado});
  Future<dynamic> aprobar({required String id});
  Future<dynamic> rechazar({required String id, String? motivo});
}

class SolicitudClienteServiceImpl implements SolicitudClienteService {
  final ApiClient apiClient;

  SolicitudClienteServiceImpl({required this.apiClient});

  @override
  Future<dynamic> crear({required CrearSolicitudClienteDto dto}) async {
    try {
      final r = await apiClient.dio.post(
        '/solicitud-cliente',
        data: dto.toJson(),
      );
      return r.data;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<List<SolicitudClienteModel>> listar({String? estado}) async {
    try {
      final r = await apiClient.dio.get(
        '/solicitud-cliente',
        queryParameters: {if (estado != null) "estado": estado},
      );
      return List<SolicitudClienteModel>.from(
        ((r.data["data"] as List?) ?? []).map(
          (x) => SolicitudClienteModel.fromJson(x),
        ),
      );
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> aprobar({required String id}) async {
    try {
      final r = await apiClient.dio.patch('/solicitud-cliente/$id/aprobar');
      return r.data;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> rechazar({required String id, String? motivo}) async {
    try {
      final r = await apiClient.dio.patch(
        '/solicitud-cliente/$id/rechazar',
        data: {if (motivo != null && motivo.trim().isNotEmpty) "motivo": motivo},
      );
      return r.data;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
