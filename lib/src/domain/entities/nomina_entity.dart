import 'package:personal/src/domain/entities/pagination_entity.dart';

/// Qué se le paga al cobrador
enum ConceptoCalculo { nomina, seguro }

extension ConceptoCalculoX on ConceptoCalculo {
  String get api => name.toUpperCase();

  static ConceptoCalculo fromApi(dynamic v) => '$v'.toUpperCase() == 'SEGURO'
      ? ConceptoCalculo.seguro
      : ConceptoCalculo.nomina;
}

/// % de la boleta (seguro) que le corresponde al cobrador
class ComisionEntity {
  final String id;
  final num? comisionPorcentaje;

  ComisionEntity({required this.id, required this.comisionPorcentaje});

  bool get configurada => comisionPorcentaje != null;
}

/// Totales de un período (del cobrador completo o de una ruta)
class TotalesNominaEntity {
  final int cajas;
  final int cajasAbiertas;
  final int diasTrabajados;
  final num cobrado;
  final num prestado;
  final num seguro;
  final num interesGenerado;
  final num gastos;

  /// Solo en SEGURO: boleta generada y su % para el cobrador
  final num? base;
  final int? montoSugerido;

  TotalesNominaEntity({
    required this.cajas,
    required this.cajasAbiertas,
    required this.diasTrabajados,
    required this.cobrado,
    required this.prestado,
    required this.seguro,
    required this.interesGenerado,
    required this.gastos,
    required this.base,
    required this.montoSugerido,
  });
}

/// Totales de una ruta; se hace un pago por cada una
class RutaCalculoNominaEntity {
  final String rutaId;
  final String rutaNombre;
  final TotalesNominaEntity totales;

  RutaCalculoNominaEntity({
    required this.rutaId,
    required this.rutaNombre,
    required this.totales,
  });
}

/// Caja del período que entró en el cálculo
class CajaCalculoNominaEntity {
  final String id;
  final String rutaId;
  final String rutaNombre;
  final DateTime? fechaOperacion;
  final String estado;
  final num cobrado;
  final num prestado;
  final num seguro;
  final num interesGenerado;
  final num gastos;

  CajaCalculoNominaEntity({
    required this.id,
    required this.rutaId,
    required this.rutaNombre,
    required this.fechaOperacion,
    required this.estado,
    required this.cobrado,
    required this.prestado,
    required this.seguro,
    required this.interesGenerado,
    required this.gastos,
  });
}

/// Tramo en que el cobrador tuvo asignada una ruta dentro del período
class AsignacionNominaEntity {
  final String rutaId;
  final String rutaNombre;
  final DateTime? inicio;
  final DateTime? fin;
  final bool vigente;

  AsignacionNominaEntity({
    required this.rutaId,
    required this.rutaNombre,
    required this.inicio,
    required this.fin,
    required this.vigente,
  });
}

/// Resumen y valor sugerido de un cobrador (no guarda nada)
class CalculoNominaEntity {
  final String cobradorId;
  final String cobradorNombre;
  final String fechaInicio;
  final String fechaFin;
  final ConceptoCalculo concepto;

  /// Null en NOMINA
  final num? comisionPorcentaje;
  final TotalesNominaEntity resumen;
  final List<RutaCalculoNominaEntity> rutas;
  final List<CajaCalculoNominaEntity> cajas;
  final List<AsignacionNominaEntity> asignaciones;

  CalculoNominaEntity({
    required this.cobradorId,
    required this.cobradorNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.concepto,
    required this.comisionPorcentaje,
    required this.resumen,
    required this.rutas,
    required this.cajas,
    required this.asignaciones,
  });
}

/// Resultado de pagar a un supervisor/admin: un pago por ruta, mismo lote
class PagoSupervisorEntity {
  final String empleadoId;
  final String lote;
  final int totalPagado;
  final List<PagoNominaEntity> pagos;

  PagoSupervisorEntity({
    required this.empleadoId,
    required this.lote,
    required this.totalPagado,
    required this.pagos,
  });
}

/// Pago de nómina (tabla propia, no es gasto de ruta)
class PagoNominaEntity {
  final String id;
  final String rutaId;
  final String rutaNombre;
  final String empleadoId;
  final String concepto;
  final num valor;
  final String observacion;
  final DateTime? fechaPago;

  /// Agrupa los pagos de un mismo pago repartido de supervisor
  final String? lote;
  final String estado;
  final String motivoAnulacion;
  final DateTime? fechaAnulacion;
  final DateTime? createdAt;

  PagoNominaEntity({
    required this.id,
    required this.rutaId,
    required this.rutaNombre,
    required this.empleadoId,
    required this.concepto,
    required this.valor,
    required this.observacion,
    required this.fechaPago,
    required this.lote,
    required this.estado,
    required this.motivoAnulacion,
    required this.fechaAnulacion,
    required this.createdAt,
  });

  bool get anulado => estado == 'ANULADO';
}

class ResumenNominaEntity {
  final int cantidad;

  /// Suma solo los pagos activos
  final num total;

  ResumenNominaEntity({required this.cantidad, required this.total});
}

class HistorialNominaEntity {
  final ResumenNominaEntity resumen;
  final List<PagoNominaEntity> pagos;
  final PaginationEntity pagination;

  HistorialNominaEntity({
    required this.resumen,
    required this.pagos,
    required this.pagination,
  });
}
