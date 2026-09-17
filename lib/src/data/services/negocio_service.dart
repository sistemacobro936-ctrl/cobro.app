import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/administrador_model.dart';
import 'package:personal/src/domain/dto/administrador_dto.dart';
import 'package:personal/src/domain/dto/registro_dto.dart';

abstract class NegocioService {
  Future<dynamic> registrar({required RegistroDto dto});

  Future<dynamic> crearAdministrador({required AdministradorDto dto});

  Future<AdministradoresModel> listarAdministradores();
}

class NegocioServiceImpl implements NegocioService {
  final ApiClient apiClient;

  NegocioServiceImpl({required this.apiClient});

  @override
  Future<dynamic> registrar({required RegistroDto dto}) async {
    try {
      final response = await apiClient.dio.post(
        '/negocio/registro',
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
  Future<dynamic> crearAdministrador({required AdministradorDto dto}) async {
    try {
      final response = await apiClient.dio.post(
        '/negocio/administradores',
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
  Future<AdministradoresModel> listarAdministradores() async {
    try {
      final response = await apiClient.dio.get('/negocio/administradores');
      return AdministradoresModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
