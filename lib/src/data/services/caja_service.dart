import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/caja_model.dart';
import 'package:personal/src/domain/dto/caja_dto.dart';

abstract class CajaService {
  Future<CajaModel> obtenerCajas({
    required String rutaId,
    required String fecha,
  });
  Future<dynamic> crearCaja({required CajaDto dto});
  Future<CajaModel> historico({required String rutaID});
}

class CajaServiceImpl implements CajaService {
  final ApiClient apiClient;

  CajaServiceImpl({required this.apiClient});
  @override
  Future<CajaModel> obtenerCajas({
    required String rutaId,
    required String fecha,
  }) async {
    try {
      final r = await apiClient.dio.get("/caja/$rutaId?q= $fecha");
      return CajaModel(
        exito: r.data["exito"],
        msg: r.data["msg"],
        data: [DatumCajaModel.fromJson(r.data["data"])],
      );
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> crearCaja({required CajaDto dto}) async {
    try {
      await apiClient.dio.post("/caja", data: dto.tojson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<CajaModel> historico({required String rutaID}) async {
    try {
      final r = await apiClient.dio.get("/caja/detalle/$rutaID");
      return CajaModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
