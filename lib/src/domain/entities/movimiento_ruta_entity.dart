class MovimientoRutaEntity {
    final bool exito;
    final String msg;
    final DataMovimientoE data;

    MovimientoRutaEntity({
        required this.exito,
        required this.msg,
        required this.data,
    });

}

class DataMovimientoE {
    final int capital;
    final int totalPrestado;
    final int gananciaEsperada;
    final int seguros;
    final int cartera;
    final int disponible;
    final int totalPrestamos;

    DataMovimientoE({
        required this.capital,
        required this.totalPrestado,
        required this.gananciaEsperada,
        required this.seguros,
        required this.cartera,
        required this.disponible,
        required this.totalPrestamos,
    });

}
