import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/mora_model.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';

abstract class MoraService {
  Future<List<RangoMoraEntity>> rangos();
  Future<List<RangoMoraEntity>> guardarRangos(List<RangoMoraEntity> rangos);

  /// [nivel]: índice del rango; [estadoCliente]: p. ej. CLAVO
  Future<AtrasadosPageModel> atrasados({
    int? nivel,
    String? estadoCliente,
    int page = 1,
    int limit = 20,
  });
}

class MoraServiceImpl implements MoraService {
  final ApiClient apiClient;

  MoraServiceImpl({required this.apiClient});

  @override
  Future<List<RangoMoraEntity>> rangos() async {
    try {
      final r = await apiClient.dio.get('/mora/rangos');
      return ((r.data['data'] as List?) ?? [])
          .map((x) => rangoMoraDesdeJson(x))
          .toList();
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<List<RangoMoraEntity>> guardarRangos(
    List<RangoMoraEntity> rangos,
  ) async {
    try {
      final r = await apiClient.dio.put(
        '/mora/rangos',
        data: {'rangos': rangos.map((e) => e.toJson()).toList()},
      );
      return ((r.data['data'] as List?) ?? [])
          .map((x) => rangoMoraDesdeJson(x))
          .toList();
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<AtrasadosPageModel> atrasados({
    int? nivel,
    String? estadoCliente,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final r = await apiClient.dio.get(
        '/mora/atrasados',
        queryParameters: {
          if (nivel != null) 'nivel': '$nivel',
          if (estadoCliente != null) 'estadoCliente': estadoCliente,
          'page': '$page',
          'limit': '$limit',
        },
      );
      return AtrasadosPageModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
