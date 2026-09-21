import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/gasto_model.dart';
import 'package:personal/src/data/model/gasto_ruta_model.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';
import 'package:personal/src/domain/dto/gasto_ruta_dto.dart';

abstract class GastosService {
  Future<bool> crearGasto({required CrearGastoDto dto});
  Future<GastoModel> listarGastos({required String cajaId});
  Future<bool> crearGastoRuta({required CrearGastoRutaDto dto});
  Future<GastosRutaModel> listarGastosRuta({
    required String rutaId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  });
  Future<bool> anularGastoRuta({required String id, required String motivo});
}

class GastosServiceImpl implements GastosService {
  final ApiClient apiClient;

  GastosServiceImpl({required this.apiClient});
  @override
  Future<bool> crearGasto({required CrearGastoDto dto}) async {
    try {
      await apiClient.dio.post("/gastos", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<GastoModel> listarGastos({required String cajaId}) async{
    try {
     final r = await apiClient.dio.get("/gastos/$cajaId");
      return GastoModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<bool> crearGastoRuta({required CrearGastoRutaDto dto}) async {
    try {
      await apiClient.dio.post("/gasto-ruta", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<GastosRutaModel> listarGastosRuta({
    required String rutaId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/gasto-ruta/$rutaId",
        queryParameters: {
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "page": page,
          "limit": limit,
        },
      );
      return GastosRutaModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<bool> anularGastoRuta({
    required String id,
    required String motivo,
  }) async {
    try {
      await apiClient.dio.patch(
        "/gasto-ruta/$id/anular",
        data: {"motivo": motivo},
      );
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
