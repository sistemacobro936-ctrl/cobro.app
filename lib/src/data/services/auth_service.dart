
import 'package:dio/dio.dart';
import 'package:personal/src/common/error/exceptions.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/data/model/auth_model.dart';
import 'package:personal/src/domain/dto/auth_dto.dart';

abstract class AuthService {
  Future<AuthModel> login({required AuthDto dto});
}

class AuthServiceImpl implements AuthService {
  final ApiClient apiClient;

  AuthServiceImpl({required this.apiClient});

  @override
  Future<AuthModel> login({required AuthDto dto}) async {
    try {
      final response = await apiClient.dio.post(
        '/credencial/login',
        data: dto.toJson(),
      );

      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerExceptions(message:  e.response!.data["message"]);
    } catch (e) {
      throw Exception("Error inesperado");
    }
  }
}
