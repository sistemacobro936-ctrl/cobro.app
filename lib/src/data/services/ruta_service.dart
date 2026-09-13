import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/data/model/detalle_ruta_model.dart';
import 'package:personal/src/data/model/movimiento_ruta_model.dart';
import 'package:personal/src/data/model/ruta_model.dart';
import 'package:personal/src/domain/dto/ruta_dto.dart';

abstract class RutaService {
  Future<dynamic> crear({required RutaDto dto});

  Future<RutaModel> listar();
  Future<RutaModel> resumen({required String idsRuta});

  Future<List<DetalleRutaModel>> detalleRuta({
    required String idRuta,
    bool esCobro = false,
  });

  Future<bool> editar({required String id, required RutaDto dto});
  Future<RutaModel> rutaCobrador();

  Future<MovimientoRutaModel> movimiento({required String idRuta});
}

class RutaServiceImpl implements RutaService {
  final ApiClient apiClient;

  RutaServiceImpl({required this.apiClient});
  @override
  Future<dynamic> crear({required RutaDto dto}) async {
    try {
      await apiClient.dio.post("/ruta", data: dto.toJson());
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<RutaModel> listar() async {
    try {
      final r = await apiClient.dio.get("/ruta");

      return RutaModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<List<DetalleRutaModel>> detalleRuta({
    required String idRuta,
    bool esCobro = false,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/ruta/$idRuta",
        queryParameters: {
          "esCobro": esCobro.toString(),
          "fechaOperacion": DateUtil.formatDate(DateTime.now()),
        },
      );

      return (r.data["data"] as List)
          .map((e) => DetalleRutaModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<bool> editar({required String id, required RutaDto dto}) async {
    try {
      await apiClient.dio.patch("/ruta/$id", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<RutaModel> rutaCobrador() async {
    try {
      final response = await apiClient.dio.get('/ruta/cobrador');

      return RutaModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<RutaModel> resumen({required String idsRuta}) async {
    try {
      final r = await apiClient.dio.get(
        "/ruta/resumen/$idsRuta",
        queryParameters: {
          "fechaOperacion": DateUtil.formatDate(DateTime.now()),
        },
      );
      return RutaModel(
        data: [DatumRModel.fromJson(r.data["data"])],
        exito: true,
        msg: "Operación exitosa.",
      );
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<MovimientoRutaModel> movimiento({required String idRuta}) async {
    try {
      final r = await apiClient.dio.get("/ruta/movimiento/$idRuta");
      return MovimientoRutaModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
