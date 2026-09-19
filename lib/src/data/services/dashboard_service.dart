import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/dashboard_model.dart';

abstract class DashboardService {
  Future<DashboardModel> resumen({required String fecha, required int limit});

  Future<ActividadPageModel> actividad({
    required String fecha,
    String? tipo,
    required int page,
    required int limit,
  });
}

class DashboardServiceImpl implements DashboardService {
  final ApiClient apiClient;

  DashboardServiceImpl({required this.apiClient});

  @override
  Future<DashboardModel> resumen({
    required String fecha,
    required int limit,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/dashboard/resumen",
        queryParameters: {"fechaOperacion": fecha, "limit": limit},
      );
      return DashboardModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<ActividadPageModel> actividad({
    required String fecha,
    String? tipo,
    required int page,
    required int limit,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/dashboard/actividad",
        queryParameters: {
          "fechaOperacion": fecha,
          "tipo": ?tipo,
          "page": page,
          "limit": limit,
        },
      );
      return ActividadPageModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
