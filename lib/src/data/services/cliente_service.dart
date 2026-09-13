import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/cliente_model.dart';
import 'package:personal/src/domain/dto/crear_cliente_dto.dart';

abstract class ClienteService {
  Future<ClienteModel> listar();
  Future<ClienteModel> clientesPorRuta({
    required String idRuta,
    int page = 1,
    int limit = 10,
  });
  Future<ClienteModel> buscar({required String q});

  Future<String> crear({required CrearClienteDto dto});
  Future<dynamic> editar({required CrearClienteDto dto, required String id});
  Future<DatumClModel> obtenerCliente({required String id});
}

class ClienteServiceImpl implements ClienteService {
  final ApiClient apiClient;

  ClienteServiceImpl({required this.apiClient});

  @override
  Future<ClienteModel> listar() async {
    try {
      final response = await apiClient.dio.get('/cliente');

      return ClienteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<String> crear({required CrearClienteDto dto}) async {
    try {
      final response = await apiClient.dio.post('/cliente', data: dto.toJson());

      return response.data["data"]["id"];
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<DatumClModel> obtenerCliente({required String id}) async {
    try {
      final r = await apiClient.dio.get("/cliente/$id");
      return DatumClModel.fromJson(r.data["data"]);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> editar({
    required CrearClienteDto dto,
    required String id,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        '/cliente/$id',
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
  Future<ClienteModel> buscar({required String q}) async {
    try {
      final r = await apiClient.dio.get("/cliente/buscar?q=$q");
      return ClienteModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<ClienteModel> clientesPorRuta({
    required String idRuta,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/cliente/ruta/$idRuta',
        queryParameters: {"page": "$page", "limit": "$limit"},
      );

      return ClienteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
