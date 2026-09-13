// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'package:personal/src/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel({required super.accessToken, required super.usuario});

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    accessToken: json["accessToken"],
    usuario: UsuarioModel.fromJson(json["usuario"]),
  );
}

class UsuarioModel extends UsuarioEntity {
  UsuarioModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    id: json["id"],
    nombre: json["nombre"]??"",
    apellido: json["apellido"] ??"",
    email: json["email"] ??"",
  );
}
