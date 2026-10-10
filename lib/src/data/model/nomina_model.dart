import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';

/// El backend puede mandar montos como número o como string (decimal)
num _num(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;

num? _numOrNull(dynamic v) => v == null ? null : num.tryParse('$v');

class ComisionModel extends ComisionEntity {
  ComisionModel({required super.id, required super.comisionPorcentaje});

  factory ComisionModel.fromJson(Map<String, dynamic> json) => ComisionModel(
    id: json['id'] ?? '',
    comisionPorcentaje: _numOrNull(json['comisionPorcentaje']),
  );
}

class TotalesNominaModel extends TotalesNominaEntity {
  TotalesNominaModel({
    required super.cajas,
    required super.cajasAbiertas,
    required super.diasTrabajados,
    required super.cobrado,
    required super.prestado,
    required super.seguro,
    required super.interesGenerado,
    required super.gastos,
    required super.base,
    required super.montoSugerido,
  });

  factory TotalesNominaModel.fromJson(Map<String, dynamic> json) =>
      TotalesNominaModel(
        cajas: _num(json['cajas']).toInt(),
        cajasAbiertas: _num(json['cajasAbiertas']).toInt(),
        diasTrabajados: _num(json['diasTrabajados']).toInt(),
        cobrado: _num(json['cobrado']),
        prestado: _num(json['prestado']),
        seguro: _num(json['seguro']),
        interesGenerado: _num(json['interesGenerado']),
        gastos: _num(json['gastos']),
        base: _numOrNull(json['base']),
        montoSugerido: _numOrNull(json['montoSugerido'])?.round(),
      );
}

class CalculoNominaModel extends CalculoNominaEntity {
  CalculoNominaModel({
    required super.cobradorId,
    required super.cobradorNombre,
    required super.fechaInicio,
    required super.fechaFin,
    required super.concepto,
    required super.comisionPorcentaje,
    required super.resumen,
    required super.rutas,
    required super.cajas,
    required super.asignaciones,
  });

  factory CalculoNominaModel.fromJson(Map<String, dynamic> json) =>
      CalculoNominaModel(
        cobradorId: json['cobradorId'] ?? '',
        cobradorNombre: json['cobradorNombre'] ?? '',
        fechaInicio: '${json['fechaInicio'] ?? ''}',
        fechaFin: '${json['fechaFin'] ?? ''}',
        concepto: ConceptoCalculoX.fromApi(json['concepto']),
        comisionPorcentaje: _numOrNull(json['comisionPorcentaje']),
        resumen: TotalesNominaModel.fromJson(
          (json['resumen'] as Map<String, dynamic>?) ?? {},
        ),
        rutas: ((json['rutas'] as List?) ?? [])
            .map(
              (x) => RutaCalculoNominaEntity(
                rutaId: x['rutaId'] ?? '',
                rutaNombre: x['rutaNombre'] ?? '',
                totales: TotalesNominaModel.fromJson(x),
              ),
            )
            .toList(),
        cajas: ((json['cajas'] as List?) ?? [])
            .map(
              (x) => CajaCalculoNominaEntity(
                id: x['id'] ?? '',
                rutaId: x['rutaId'] ?? '',
                rutaNombre: x['rutaNombre'] ?? '',
                // Sin toLocal: es una fecha sin hora y podría correrse de día
                fechaOperacion: DateTime.tryParse('${x['fechaOperacion']}'),
                estado: x['estado'] ?? '',
                cobrado: _num(x['cobrado']),
                prestado: _num(x['prestado']),
                seguro: _num(x['seguro']),
                interesGenerado: _num(x['interesGenerado']),
                gastos: _num(x['gastos']),
              ),
            )
            .toList(),
        asignaciones: ((json['asignaciones'] as List?) ?? [])
            .map(
              (x) => AsignacionNominaEntity(
                rutaId: x['rutaId'] ?? '',
                rutaNombre: x['rutaNombre'] ?? '',
                // Vienen en UTC: se muestran en hora de Bogotá
                inicio: DateTime.tryParse('${x['inicio']}')?.toLocal(),
                fin: DateTime.tryParse('${x['fin']}')?.toLocal(),
                vigente: x['vigente'] ?? false,
              ),
            )
            .toList(),
      );
}

class PagoSupervisorModel extends PagoSupervisorEntity {
  PagoSupervisorModel({
    required super.empleadoId,
    required super.lote,
    required super.totalPagado,
    required super.pagos,
  });

  factory PagoSupervisorModel.fromJson(Map<String, dynamic> json) =>
      PagoSupervisorModel(
        empleadoId: json['empleadoId'] ?? '',
        lote: '${json['lote'] ?? ''}',
        totalPagado: _num(json['totalPagado']).round(),
        pagos: ((json['pagos'] as List?) ?? [])
            .map((x) => PagoNominaModel.fromJson(x))
            .toList(),
      );
}

class PagoNominaModel extends PagoNominaEntity {
  PagoNominaModel({
    required super.id,
    required super.rutaId,
    required super.rutaNombre,
    required super.empleadoId,
    required super.concepto,
    required super.valor,
    required super.observacion,
    required super.fechaPago,
    required super.lote,
    required super.estado,
    required super.motivoAnulacion,
    required super.fechaAnulacion,
    required super.createdAt,
  });

  factory PagoNominaModel.fromJson(Map<String, dynamic> json) =>
      PagoNominaModel(
        id: json['id'] ?? '',
        rutaId: json['rutaId'] ?? '',
        rutaNombre: json['rutaNombre'] ?? '',
        empleadoId: json['empleadoId'] ?? '',
        concepto: json['concepto'] ?? '',
        valor: _num(json['valor']),
        observacion: json['observacion'] ?? '',
        // Sin toLocal: es una fecha sin hora y podría correrse de día
        fechaPago: DateTime.tryParse('${json['fechaPago']}'),
        lote: json['lote'],
        estado: json['estado'] ?? 'ACTIVO',
        motivoAnulacion: json['motivoAnulacion'] ?? '',
        // Con hora, en UTC: se muestra en hora de Bogotá
        fechaAnulacion: DateTime.tryParse(
          '${json['fechaAnulacion']}',
        )?.toLocal(),
        createdAt: DateTime.tryParse('${json['createdAt']}')?.toLocal(),
      );
}

class HistorialNominaModel extends HistorialNominaEntity {
  HistorialNominaModel({
    required super.resumen,
    required super.pagos,
    required super.pagination,
  });

  /// Recibe la respuesta completa `{ exito, msg, data: { resumen, pagos }, pagination }`
  factory HistorialNominaModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final resumen = (data['resumen'] as Map<String, dynamic>?) ?? {};

    return HistorialNominaModel(
      resumen: ResumenNominaEntity(
        cantidad: _num(resumen['cantidad']).toInt(),
        total: _num(resumen['total']),
      ),
      pagos: List<PagoNominaEntity>.from(
        ((data['pagos'] as List?) ?? []).map(
          (x) => PagoNominaModel.fromJson(x),
        ),
      ),
      pagination: PaginationModel.fromJson(
        (json['pagination'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
