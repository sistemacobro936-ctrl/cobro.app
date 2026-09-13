import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/cobrador_model.dart';
import 'package:personal/src/domain/dto/crear_cobrador_dto.dart';

abstract class UsuarioService {
  Future<CobradorModel> listarCobradores();
  Future<DatumCModel> detalleCobrador({required String id});
  Future<dynamic> crearCobrador({required CrearCobradorDto dto});
  Future<dynamic> editarCobrador({
    required String id,
    required CrearCobradorDto dto,
  });
}

class UsuarioServiceImpl implements UsuarioService {
  final ApiClient apiClient;

  UsuarioServiceImpl({required this.apiClient});

  @override
  Future<CobradorModel> listarCobradores() async {
    try {
      final response = await apiClient.dio.get('/usuario/cobradores');

      return CobradorModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> crearCobrador({required CrearCobradorDto dto}) async {
    try {
      final response = await apiClient.dio.post(
        '/usuario/cobrador',
        data: dto.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<DatumCModel> detalleCobrador({required String id}) async {
    try {
      final response = await apiClient.dio.get('/usuario/cobrador/$id');

      return DatumCModel.fromJson(response.data["data"]);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> editarCobrador({
    required String id,
    required CrearCobradorDto dto,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        '/usuario/cobrador/$id',
        data: dto.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
