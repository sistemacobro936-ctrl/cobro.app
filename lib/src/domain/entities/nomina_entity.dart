import 'package:personal/src/domain/entities/pagination_entity.dart';

/// Base sobre la que se calcula la comisión de un usuario
enum ComisionBase { cobrado, prestado, seguro }

extension ComisionBaseX on ComisionBase {
  String get api => name.toUpperCase();

  String get titulo => switch (this) {
    ComisionBase.cobrado => 'Cobrado',
    ComisionBase.prestado => 'Prestado',
    ComisionBase.seguro => 'Seguro',
  };

  String get descripcion => switch (this) {
    ComisionBase.cobrado =>
      '% de lo cobrado (pagos aplicados) en la ruta durante el período.',
    ComisionBase.prestado =>
      '% de lo prestado (préstamos nuevos) en la ruta durante el período.',
    ComisionBase.seguro =>
      '% del seguro (boletas) de los préstamos nuevos del período.',
  };

  static ComisionBase? fromApi(dynamic v) {
    for (final b in ComisionBase.values) {
      if (b.api == '$v'.toUpperCase()) return b;
    }
    return null;
  }
}

/// Comisión configurada de un usuario; ambos campos en null = sin configurar
class ComisionEntity {
  final String id;
  final ComisionBase? comisionBase;
  final num? comisionPorcentaje;

  ComisionEntity({
    required this.id,
    required this.comisionBase,
    required this.comisionPorcentaje,
  });

  bool get configurada => comisionBase != null && comisionPorcentaje != null;
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

  /// Null si el cobrador no tiene comisión configurada
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

/// Totales de una ruta; se paga un gasto por cada una
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

/// Resumen y nómina sugerida de un cobrador (no guarda nada)
class CalculoNominaEntity {
  final String cobradorNombre;
  final bool comisionConfigurada;
  final ComisionBase? comisionBase;
  final num? comisionPorcentaje;
  final TotalesNominaEntity resumen;
  final List<RutaCalculoNominaEntity> rutas;
  final List<CajaCalculoNominaEntity> cajas;
  final List<AsignacionNominaEntity> asignaciones;

  CalculoNominaEntity({
    required this.cobradorNombre,
    required this.comisionConfigurada,
    required this.comisionBase,
    required this.comisionPorcentaje,
    required this.resumen,
    required this.rutas,
    required this.cajas,
    required this.asignaciones,
  });
}

/// Resultado de pagar a un supervisor/admin repartido entre rutas
class PagoSupervisorEntity {
  final String empleadoId;
  final int totalPagado;
  final int cantidadGastos;

  PagoSupervisorEntity({
    required this.empleadoId,
    required this.totalPagado,
    required this.cantidadGastos,
  });
}

/// Pago de nómina del historial de un empleado
class PagoNominaEntity {
  final String id;
  final String rutaId;
  final String rutaNombre;
  final String concepto;
  final num valor;
  final DateTime? fechaGasto;
  final String estado;

  PagoNominaEntity({
    required this.id,
    required this.rutaId,
    required this.rutaNombre,
    required this.concepto,
    required this.valor,
    required this.fechaGasto,
    required this.estado,
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
