import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/config_model.dart';
import 'package:personal/src/domain/dto/config_dto.dart';

abstract class ConfiguracionService {
  Future<ConfigModel> obtenerConfiguracion();

  Future<dynamic> guardarConfiguracion({required ConfigDto dto});
}

class ConfiguracionServiceImpl implements ConfiguracionService {
  final ApiClient apiClient;

  ConfiguracionServiceImpl({required this.apiClient});

  @override
  Future<ConfigModel> obtenerConfiguracion() async {
    try {
      final response = await apiClient.dio.get('/confi-prestamo/prestamos');

      return ConfigModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> guardarConfiguracion({required ConfigDto dto}) async {
    try {
      final response = await apiClient.dio.post(
        '/confi-prestamo/prestamos',
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
