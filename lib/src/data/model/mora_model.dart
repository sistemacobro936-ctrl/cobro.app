import 'package:personal/src/data/model/pagination_model.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';

RangoMoraEntity rangoMoraDesdeJson(Map<String, dynamic> json) =>
    RangoMoraEntity(
      desde: (json['desde'] as num?)?.toInt() ?? 1,
      hasta: (json['hasta'] as num?)?.toInt(),
      colorHex: json['color'] ?? '#8A93A3',
      etiqueta: json['etiqueta'] ?? '',
    );

NivelMoraEntity nivelMoraDesdeJson(Map<String, dynamic> json) =>
    NivelMoraEntity(
      indice: (json['indice'] as num?)?.toInt() ?? 0,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      saldo: json['saldo'] ?? 0,
      desde: (json['desde'] as num?)?.toInt() ?? 1,
      hasta: (json['hasta'] as num?)?.toInt(),
      colorHex: json['color'] ?? '#8A93A3',
      etiqueta: json['etiqueta'] ?? '',
    );

class AtrasadosPageModel extends AtrasadosPageEntity {
  const AtrasadosPageModel({
    required super.data,
    required super.resumen,
    required super.pagination,
  });

  /// Recibe la respuesta completa `{ exito, msg, data, resumen, pagination }`
  factory AtrasadosPageModel.fromJson(Map<String, dynamic> json) {
    final resumen = (json['resumen'] as Map<String, dynamic>?) ?? {};

    return AtrasadosPageModel(
      data: ((json['data'] as List?) ?? []).map((x) {
        final cliente = (x['cliente'] as Map<String, dynamic>?) ?? {};
        return AtrasadoEntity(
          prestamoId: x['prestamoId'] ?? '',
          monto: x['monto'] ?? 0,
          totalPagar: x['totalPagar'] ?? 0,
          saldo: x['saldo'] ?? 0,
          fechaFin: x['fechaFin'] ?? '',
          diasAtraso: (x['diasAtraso'] as num?)?.toInt() ?? 0,
          nivel: x['nivel'] == null ? null : nivelMoraDesdeJson(x['nivel']),
          clienteId: cliente['id'] ?? '',
          nombres: cliente['nombres'] ?? '',
          apellidos: cliente['apellidos'] ?? '',
          cedula: cliente['cedula'] ?? '',
          telefono: cliente['telefono'] ?? '',
          estadoCliente: cliente['estado'] ?? '',
          rutaNombre: x['rutaNombre'] ?? '',
        );
      }).toList(),
      resumen: ResumenMoraEntity(
        total: (resumen['total'] as num?)?.toInt() ?? 0,
        clavos: (resumen['clavos'] as num?)?.toInt() ?? 0,
        niveles: ((resumen['niveles'] as List?) ?? [])
            .map((x) => nivelMoraDesdeJson(x))
            .toList(),
      ),
      pagination: PaginationModel.fromJson(
        (json['pagination'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
