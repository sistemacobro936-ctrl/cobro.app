import 'package:personal/src/domain/entities/administrador_entity.dart';

class AdministradoresModel extends AdministradoresEntity {
  AdministradoresModel({
    required super.exito,
    required super.msg,
    required super.data,
  });

  factory AdministradoresModel.fromJson(Map<String, dynamic> json) =>
      AdministradoresModel(
        exito: json["exito"] ?? false,
        msg: json["msg"] ?? "",
        data: json["data"] == null
            ? []
            : List<DatumAdministradorModel>.from(
                json["data"].map((x) => DatumAdministradorModel.fromJson(x)),
              ),
      );
}

class DatumAdministradorModel extends DatumAdministradorEntity {
  DatumAdministradorModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.documento,
    required super.telefono,
    required super.email,
    required super.estado,
  });

  factory DatumAdministradorModel.fromJson(Map<String, dynamic> json) =>
      DatumAdministradorModel(
        id: json["id"] ?? "",
        nombre: json["nombre"] ?? "",
        apellido: json["apellido"] ?? "",
        documento: json["documento"] ?? "",
        telefono: json["telefono"] ?? "",
        email: json["email"] ?? "",
        estado: json["estado"] ?? "",
      );
}
