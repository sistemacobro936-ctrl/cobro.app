
class ConfigDto {
    final ConfiguracionDto configuracion;
    final List<DiasCobroDto> diasCobro;
    final List<PeriodosCobroDto> periodosCobro;

    ConfigDto({
        required this.configuracion,
        required this.diasCobro,
        required this.periodosCobro,
    });

   

    Map<String, dynamic> toJson() => {
        "configuracion": configuracion.toJson(),
        "diasCobro": List<dynamic>.from(diasCobro.map((x) => x.toJson())),
        "periodosCobro": List<dynamic>.from(periodosCobro.map((x) => x.toJson())),
    };
}

class ConfiguracionDto {
    final int interesDefault;
    final int seguroDefault;

    ConfiguracionDto({
        required this.interesDefault,
        required this.seguroDefault,
    });

   

    Map<String, dynamic> toJson() => {
        "interesDefault": interesDefault,
        "seguroDefault": seguroDefault,
    };
}

class DiasCobroDto {
    final int diaSemana;
    final String nombre;
    final bool habilitado;

    DiasCobroDto({
        required this.diaSemana,
        required this.nombre,
        required this.habilitado,
    });

  

    Map<String, dynamic> toJson() => {
        "diaSemana": diaSemana,
        "nombre": nombre,
        "habilitado": habilitado,
    };
}

class PeriodosCobroDto {
    final String codigo;
    final String nombre;
    final int cantidadDias;
    final bool habilitado;

    PeriodosCobroDto({
        required this.codigo,
        required this.nombre,
        required this.cantidadDias,
        required this.habilitado,
    });



    Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "nombre": nombre,
        "cantidadDias": cantidadDias,
        "habilitado": habilitado,
    };
}
