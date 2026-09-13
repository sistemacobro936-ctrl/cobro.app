
import 'package:personal/src/domain/entities/config_entity.dart';

class ConfigModel extends ConfigEntity {
  ConfigModel({required super.exito, required super.msg, required super.data});

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
    exito: json["exito"],
    msg: json["msg"],
    data: DataConModel.fromJson(json["data"]),
  );
}

class DataConModel extends DataConEntity {
  DataConModel({
    required super.configuracion,
    required super.diasCobro,
    required super.periodosCobro,
  });

  factory DataConModel.fromJson(Map<String, dynamic> json) => DataConModel(
    configuracion: ConfiguracionModel.fromJson(json["configuracion"]),
    diasCobro: List<SCobroModel>.from(
      json["diasCobro"].map((x) => SCobroModel.fromJson(x)),
    ),
    periodosCobro: List<SCobroModel>.from(
      json["periodosCobro"].map((x) => SCobroModel.fromJson(x)),
    ),
  );
}

class ConfiguracionModel extends ConfiguracionEntity {
  ConfiguracionModel({
    required super.id,
    required super.adminId,
    required super.interesDefault,
    required super.seguroDefault,
    required super.estado,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConfiguracionModel.fromJson(Map<String, dynamic> json) =>
      ConfiguracionModel(
        id: json["id"],
        adminId: json["adminId"],
        interesDefault: json["interesDefault"],
        seguroDefault: json["seguroDefault"],
        estado: json["estado"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );
}

class SCobroModel extends SCobroEntity {
  SCobroModel({
    required super.id,
    required super.adminId,
    super.diaSemana,
    super.cuotas,
    required super.nombre,
    required super.habilitado,
    required super.createdAt,
    required super.updatedAt,
    super.codigo,
    super.cantidadDias,
  });

  factory SCobroModel.fromJson(Map<String, dynamic> json) => SCobroModel(
    id: json["id"],
    adminId: json["adminId"],
    diaSemana: json["diaSemana"],
    cuotas: json["cuotas"],
    nombre: json["nombre"],
    habilitado: json["habilitado"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    codigo: json["codigo"],
    cantidadDias: json["cantidadDias"],
  );
}
