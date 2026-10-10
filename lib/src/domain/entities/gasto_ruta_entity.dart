import 'package:personal/src/domain/entities/pagination_entity.dart';

/// Gasto de una ruta que no depende de una caja del día
class GastoRutaEntity {
  final String id;
  final String rutaId;
  final String concepto;
  final num valor;
  final String observacion;
  final DateTime? fechaGasto;
  final String estado;
  final String registradoPorNombre;
  final String motivoAnulacion;

  GastoRutaEntity({
    required this.id,
    required this.rutaId,
    required this.concepto,
    required this.valor,
    required this.observacion,
    required this.fechaGasto,
    required this.estado,
    required this.registradoPorNombre,
    required this.motivoAnulacion,
  });

  bool get anulado => estado == 'ANULADO';
}

class ResumenGastosRutaEntity {
  final int cantidad;

  /// Suma solo los gastos activos del rango completo
  final num total;

  ResumenGastosRutaEntity({required this.cantidad, required this.total});
}

class GastosRutaEntity {
  final ResumenGastosRutaEntity resumen;
  final List<GastoRutaEntity> gastos;
  final PaginationEntity pagination;

  GastosRutaEntity({
    required this.resumen,
    required this.gastos,
    required this.pagination,
  });
}
