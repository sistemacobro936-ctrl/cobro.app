class GastoEntity {
  final bool exito;
  final String msg;
  final DataGastoEntity data;

  GastoEntity({required this.exito, required this.msg, required this.data});
}

class DataGastoEntity {
  final List<GastoElementEntity> gastos;

  DataGastoEntity({required this.gastos});
}

class GastoElementEntity {
  final String id;
  final String cajaId;
  final String concepto;
  final int valor;
  final String observacion;
  final DateTime fecha;

  GastoElementEntity({
    required this.id,
    required this.cajaId,
    required this.concepto,
    required this.valor,
    required this.observacion,
    required this.fecha,
  });
}
