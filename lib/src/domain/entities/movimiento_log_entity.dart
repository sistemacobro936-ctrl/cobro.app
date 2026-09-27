import 'package:personal/src/domain/entities/pagination_entity.dart';

/// Bitácora de eventos de una ruta (GET /movimientos/ruta/:rutaId): quién
/// hizo qué y cuándo (edición de ruta, inyección de capital, etc.).
class MovimientoLogEntity {
  final bool exito;
  final String msg;
  final List<DatumMovimientoLogEntity> data;
  final PaginationEntity? pagination;

  MovimientoLogEntity({
    required this.exito,
    required this.msg,
    required this.data,
    this.pagination,
  });
}

class DatumMovimientoLogEntity {
  final String id;
  final String negocioId;
  final String usuarioId;
  final String tipo;
  final String descripcion;
  final String referenciaId;
  final DateTime createdAt;

  DatumMovimientoLogEntity({
    required this.id,
    required this.negocioId,
    required this.usuarioId,
    required this.tipo,
    required this.descripcion,
    required this.referenciaId,
    required this.createdAt,
  });
}
