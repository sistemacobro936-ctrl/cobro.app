import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/prestamo_model.dart';
import 'package:personal/src/domain/dto/crear_prestamo_dto.dart';

abstract class PrestamoService {
  Future<dynamic> crear({required CrearPrestamoDto dto});
  Future<dynamic> crearHistorico({required CrearPrestamoDto dto});
  Future<PrestamoModel> listar();
  Future<DatumPModel> detallePrestamo({required String id});
}

class PrestamoServiceImpl implements PrestamoService {
  final ApiClient apiClient;

  PrestamoServiceImpl({required this.apiClient});

  @override
  Future<dynamic> crear({required CrearPrestamoDto dto}) async {
    try {
      await apiClient.dio.post('/prestamo', data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<dynamic> crearHistorico({required CrearPrestamoDto dto}) async {
    try {
      await apiClient.dio.post('/pago/historico', data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<PrestamoModel> listar() async {
    try {
      final r = await apiClient.dio.get("/prestamo");
      return PrestamoModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<DatumPModel> detallePrestamo({required String id}) async {
    try {
      final r = await apiClient.dio.get("/prestamo/$id");
      return DatumPModel.fromJson(r.data["data"]);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
