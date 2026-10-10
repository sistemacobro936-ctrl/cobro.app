import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/nomina_model.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';

abstract class NominaService {
  Future<CalculoNominaModel> calcular({
    required String cobradorId,
    String? fechaInicio,
    String? fechaFin,
  });
  Future<bool> pagarCobrador({required PagoNominaCobradorDto dto});
  Future<PagoSupervisorModel> pagarSupervisor({
    required PagoNominaSupervisorDto dto,
  });
  Future<HistorialNominaModel> historial({
    required String empleadoId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  });
}

class NominaServiceImpl implements NominaService {
  final ApiClient apiClient;

  NominaServiceImpl({required this.apiClient});

  @override
  Future<CalculoNominaModel> calcular({
    required String cobradorId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/nomina/calcular",
        queryParameters: {
          "cobradorId": cobradorId,
          "fechaInicio": ?fechaInicio,
          "fechaFin": ?fechaFin,
        },
      );
      return CalculoNominaModel.fromJson(r.data["data"]);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<bool> pagarCobrador({required PagoNominaCobradorDto dto}) async {
    try {
      await apiClient.dio.post("/nomina/cobrador", data: dto.toJson());
      return true;
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<PagoSupervisorModel> pagarSupervisor({
    required PagoNominaSupervisorDto dto,
  }) async {
    try {
      final r = await apiClient.dio.post(
        "/nomina/supervisor",
        data: dto.toJson(),
      );
      return PagoSupervisorModel.fromJson(r.data["data"]);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }

  @override
  Future<HistorialNominaModel> historial({
    required String empleadoId,
    required String fechaInicio,
    required String fechaFin,
    required int page,
    required int limit,
  }) async {
    try {
      final r = await apiClient.dio.get(
        "/nomina/historial/$empleadoId",
        queryParameters: {
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "page": page,
          "limit": limit,
        },
      );
      return HistorialNominaModel.fromJson(r.data);
    } on DioException catch (e) {
      throw ServerExceptions(message: e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
