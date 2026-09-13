import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/gasto_model.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';

abstract class GastosService {
  Future<bool> crearGasto({required CrearGastoDto dto});
  Future<GastoModel> listarGastos({required String cajaId});
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
}
