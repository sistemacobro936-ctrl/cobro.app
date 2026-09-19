import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/pago_ruta_model.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';

abstract class PagoService {
  Future<dynamic> pagar({required PagoDto dto});
  Future<dynamic> noPago({required NoPagoDto dto});
  Future<List<PagoRutaModel>> pagosRuta({
    required String rutaId,
    required String fecha,
  });
  Future<List<NoPagoRutaModel>> noPagosRuta({
    required String rutaId,
    required String fecha,
  });
  Future<dynamic> revertirPago({required String idPago});
}

class PagoServiceImpl implements PagoService {
  final ApiClient apiClient;

  PagoServiceImpl({required this.apiClient});

  @override
  Future<dynamic> pagar({required PagoDto dto}) async {
    try {
      await apiClient.dio.post("/pago", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> noPago({required NoPagoDto dto}) async {
    try {
      await apiClient.dio.post("/pago/no-pago", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<List<PagoRutaModel>> pagosRuta({
    required String rutaId,
    required String fecha,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/pago/ruta/$rutaId",
        queryParameters: {"fechaOperacion": fecha},
      );
      return List<PagoRutaModel>.from(
        (r.data["data"] as List).map((x) => PagoRutaModel.fromJson(x)),
      );
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<List<NoPagoRutaModel>> noPagosRuta({
    required String rutaId,
    required String fecha,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/pago/no-pago/ruta/$rutaId",
        queryParameters: {"fechaOperacion": fecha},
      );
      return List<NoPagoRutaModel>.from(
        (r.data["data"] as List).map((x) => NoPagoRutaModel.fromJson(x)),
      );
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> revertirPago({required String idPago}) async {
    try {
      await apiClient.dio.patch("/pago/$idPago/reversar",data:{
         "motivoReversion":"pago revertido"
      });
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
