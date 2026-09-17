import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/reporte_model.dart';

abstract class ContabilidadService {
  Future<ReporteCajaModel> obtenerCaja({required String cajaId});

  Future<ReporteNegocioModel> obtenerNegocio({
    required String fechaInicio,
    required String fechaFin,
  });
}

class ContabilidadServiceImpl implements ContabilidadService {
  final ApiClient apiClient;

  ContabilidadServiceImpl({required this.apiClient});

  @override
  Future<ReporteCajaModel> obtenerCaja({required String cajaId}) async {
    try {
      final r = await apiClient.dio.get("/contabilidad/caja/$cajaId");
      return ReporteCajaModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<ReporteNegocioModel> obtenerNegocio({
    required String fechaInicio,
    required String fechaFin,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/contabilidad/negocio",
        queryParameters: {"fechaInicio": fechaInicio, "fechaFin": fechaFin},
      );
      return ReporteNegocioModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
