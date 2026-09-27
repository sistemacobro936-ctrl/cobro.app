import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/movimiento_log_model.dart';

abstract class MovimientoService {
  Future<MovimientoLogModel> listarPorRuta({
    required String rutaId,
    String? tipo,
    int page = 1,
    int limit = 20,
  });
}

class MovimientoServiceImpl implements MovimientoService {
  final ApiClient apiClient;

  MovimientoServiceImpl({required this.apiClient});

  @override
  Future<MovimientoLogModel> listarPorRuta({
    required String rutaId,
    String? tipo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/movimientos/ruta/$rutaId',
        queryParameters: {
          "page": "$page",
          "limit": "$limit",
          if (tipo != null && tipo.isNotEmpty) "tipo": tipo,
        },
      );

      return MovimientoLogModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
