import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/caja_model.dart';
import 'package:personal/src/data/model/movimientos_caja_model.dart';
import 'package:personal/src/domain/dto/caja_dto.dart';

abstract class CajaService {
  Future<CajaModel> obtenerCajas({
    required String rutaId,
    required String fecha,
  });
  Future<dynamic> crearCaja({required CajaDto dto});
  Future<dynamic> cerrar({required String cajaId, required CajaDto dto});
  Future<CajaModel> historico({required String rutaID});
  Future<dynamic> inyectarCapital({
    required String cajaId,
    required int valor,
    String? observacion,
  });
  Future<MovimientosCajaModel> movimientos({required String cajaId});
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
      await apiClient.dio.post("/caja", data: dto.toJson());
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

  @override
  Future<dynamic> cerrar({required String cajaId, required CajaDto dto}) async {
    try {
      await apiClient.dio.post("/caja/cerrar/$cajaId", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> inyectarCapital({
    required String cajaId,
    required int valor,
    String? observacion,
  }) async {
    try {
      await apiClient.dio.post(
        "/caja/$cajaId/inyeccion-capital",
        data: {
          "valor": valor,
          if (observacion != null && observacion.isNotEmpty)
            "observacion": observacion,
        },
      );
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<MovimientosCajaModel> movimientos({required String cajaId}) async {
    try {
      final r = await apiClient.dio.get("/caja/$cajaId/movimientos");
      return MovimientosCajaModel.fromJson(r.data["data"]);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
