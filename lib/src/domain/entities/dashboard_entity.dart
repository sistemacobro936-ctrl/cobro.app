import 'package:personal/src/domain/entities/pagination_entity.dart';

/// Tipos de evento de la actividad reciente. [otro] cubre códigos desconocidos.
enum TipoActividad {
  pago('PAGO'),
  noPago('NO_PAGO'),
  prestamo('PRESTAMO'),
  gasto('GASTO'),
  otro('');

  final String codigo;

  const TipoActividad(this.codigo);

  static TipoActividad desde(String? codigo) {
    for (final t in values) {
      if (t.codigo == codigo) return t;
    }
    return otro;
  }
}

class DashboardEntity {
  final DateTime? fechaOperacion;
  final String adminNombre;
  final String adminApellido;
  final int clientesActivos;
  final int cobradores;
  final CarteraEntity cartera;
  final List<ActividadEntity> actividadReciente;

  DashboardEntity({
    required this.fechaOperacion,
    required this.adminNombre,
    required this.adminApellido,
    required this.clientesActivos,
    required this.cobradores,
    required this.cartera,
    required this.actividadReciente,
  });
}

class CarteraEntity {
  final num total;
  final num cobroEsperadoHoy;
  final num recaudadoHoy;

  /// Porcentaje; puede pasar de 100
  final double cumplimientoHoy;
  final num atrasado;

  CarteraEntity({
    required this.total,
    required this.cobroEsperadoHoy,
    required this.recaudadoHoy,
    required this.cumplimientoHoy,
    required this.atrasado,
  });
}

class ActividadEntity {
  final String id;
  final String tipoCodigo;
  final String? clienteNombre;
  final String rutaNombre;
  final num valor;
  final DateTime? fecha;

  /// Solo en NO_PAGO
  final String? motivo;
  final DateTime? fechaPromesa;

  /// Solo en GASTO
  final String? concepto;

  ActividadEntity({
    required this.id,
    required this.tipoCodigo,
    required this.clienteNombre,
    required this.rutaNombre,
    required this.valor,
    required this.fecha,
    this.motivo,
    this.fechaPromesa,
    this.concepto,
  });

  TipoActividad get tipo => TipoActividad.desde(tipoCodigo);
}

class ActividadPageEntity {
  final List<ActividadEntity> data;
  final PaginationEntity pagination;

  ActividadPageEntity({required this.data, required this.pagination});
}
