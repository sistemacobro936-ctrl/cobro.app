import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  DashboardModel({
    required super.fechaOperacion,
    required super.adminNombre,
    required super.adminApellido,
    required super.clientesActivos,
    required super.cobradores,
    required super.cartera,
    required super.actividadReciente,
  });

  /// Recibe la respuesta completa `{ exito, msg, data }`
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final admin = (data['administrador'] as Map<String, dynamic>?) ?? {};
    final resumen = (data['resumen'] as Map<String, dynamic>?) ?? {};
    final cartera = (data['cartera'] as Map<String, dynamic>?) ?? {};

    return DashboardModel(
      fechaOperacion: DateTime.tryParse('${data['fechaOperacion']}'),
      adminNombre: admin['nombre'] ?? '',
      adminApellido: admin['apellido'] ?? '',
      clientesActivos: resumen['clientesActivos'] ?? 0,
      cobradores: resumen['cobradores'] ?? 0,
      cartera: CarteraModel.fromJson(cartera),
      actividadReciente: List<ActividadEntity>.from(
        ((data['actividadReciente'] as List?) ?? []).map(
          (x) => ActividadModel.fromJson(x),
        ),
      ),
    );
  }
}

class CarteraModel extends CarteraEntity {
  CarteraModel({
    required super.total,
    required super.cobroEsperadoHoy,
    required super.recaudadoHoy,
    required super.cumplimientoHoy,
    required super.atrasado,
  });

  factory CarteraModel.fromJson(Map<String, dynamic> json) => CarteraModel(
    total: json['total'] ?? 0,
    cobroEsperadoHoy: json['cobroEsperadoHoy'] ?? 0,
    recaudadoHoy: json['recaudadoHoy'] ?? 0,
    cumplimientoHoy: ((json['cumplimientoHoy'] ?? 0) as num).toDouble(),
    atrasado: json['atrasado'] ?? 0,
  );
}

class ActividadModel extends ActividadEntity {
  ActividadModel({
    required super.id,
    required super.tipoCodigo,
    required super.clienteNombre,
    required super.rutaNombre,
    required super.valor,
    required super.fecha,
    super.motivo,
    super.fechaPromesa,
    super.concepto,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) => ActividadModel(
    id: json['id'] ?? '',
    tipoCodigo: json['tipo'] ?? '',
    clienteNombre: json['clienteNombre'],
    rutaNombre: json['rutaNombre'] ?? '',
    valor: json['valor'] ?? 0,
    fecha: DateTime.tryParse('${json['fecha']}')?.toLocal(),
    motivo: json['motivo'],
    // Sin toLocal: es una fecha sin hora y podría correrse de día
    fechaPromesa: DateTime.tryParse('${json['fechaPromesa']}'),
    concepto: json['concepto'],
  );
}

class ActividadPageModel extends ActividadPageEntity {
  ActividadPageModel({required super.data, required super.pagination});

  /// Recibe la respuesta completa `{ exito, msg, data: [], pagination }`
  factory ActividadPageModel.fromJson(Map<String, dynamic> json) =>
      ActividadPageModel(
        data: List<ActividadEntity>.from(
          ((json['data'] as List?) ?? []).map((x) => ActividadModel.fromJson(x)),
        ),
        pagination: PaginationModel.fromJson(
          (json['pagination'] as Map<String, dynamic>?) ?? {},
        ),
      );
}
