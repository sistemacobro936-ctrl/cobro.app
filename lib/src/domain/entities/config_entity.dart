class ConfigEntity {
  final bool exito;
  final String msg;
  final DataConEntity data;

  ConfigEntity({required this.exito, required this.msg, required this.data});

  ConfigEntity copyWith({bool? exito, String? msg, DataConEntity? data}) {
    return ConfigEntity(
      exito: exito ?? this.exito,
      msg: msg ?? this.msg,
      data: data ?? this.data,
    );
  }
}

class DataConEntity {
  final ConfiguracionEntity configuracion;
  final List<SCobroEntity> diasCobro;
  final List<SCobroEntity> periodosCobro;

  DataConEntity({
    required this.configuracion,
    required this.diasCobro,
    required this.periodosCobro,
  });

  DataConEntity copyWith({
    ConfiguracionEntity? configuracion,
    List<SCobroEntity>? diasCobro,
    List<SCobroEntity>? periodosCobro,
  }) {
    return DataConEntity(
      configuracion: configuracion ?? this.configuracion,
      diasCobro: diasCobro ?? this.diasCobro,
      periodosCobro: periodosCobro ?? this.periodosCobro,
    );
  }
}

class ConfiguracionEntity {
  final String id;
  final String adminId;
  final int interesDefault;
  final int seguroDefault;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConfiguracionEntity({
    required this.id,
    required this.adminId,
    required this.interesDefault,
    required this.seguroDefault,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  ConfiguracionEntity copyWith({
    String? id,
    String? adminId,
    int? interesDefault,
    int? seguroDefault,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConfiguracionEntity(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      interesDefault: interesDefault ?? this.interesDefault,
      seguroDefault: seguroDefault ?? this.seguroDefault,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SCobroEntity {
  final String id;
  final String adminId;
  final int? diaSemana;
  final int? cuotas;
  final String nombre;
  final bool habilitado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? codigo;
  final int? cantidadDias;

  SCobroEntity({
    required this.id,
    required this.adminId,
    this.diaSemana,
    required this.nombre,
    required this.habilitado,
    required this.createdAt,
    required this.updatedAt,
    this.codigo,
    this.cantidadDias,
    this.cuotas,
  });

  SCobroEntity copyWith({
    String? id,
    String? adminId,
    int? diaSemana,
    String? nombre,
    bool? habilitado,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? codigo,
    int? cantidadDias,
    int? cuotas,
  }) {
    return SCobroEntity(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      diaSemana: diaSemana ?? this.diaSemana,
      nombre: nombre ?? this.nombre,
      habilitado: habilitado ?? this.habilitado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      codigo: codigo ?? this.codigo,
      cantidadDias: cantidadDias ?? this.cantidadDias,
      cuotas: cuotas ?? this.cuotas,
    );
  }
}
