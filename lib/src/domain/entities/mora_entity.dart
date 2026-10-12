import 'package:flutter/material.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';

/// Tramo de días de atraso. `hasta == null` = en adelante (el último).
class RangoMoraEntity {
  final int desde;
  final int? hasta;

  /// Hex #RRGGBB
  final String colorHex;
  final String etiqueta;

  const RangoMoraEntity({
    required this.desde,
    required this.hasta,
    required this.colorHex,
    required this.etiqueta,
  });

  Color get color => colorDesdeHex(colorHex);

  /// "1 a 4 días" / "60 días o más"
  String get textoDias => hasta == null
      ? '$desde ${desde == 1 ? 'día' : 'días'} o más'
      : desde == hasta
      ? '$desde ${desde == 1 ? 'día' : 'días'}'
      : '$desde a $hasta días';

  Map<String, dynamic> toJson() => {
    'desde': desde,
    'hasta': hasta,
    'color': colorHex,
    'etiqueta': etiqueta,
  };
}

/// Un nivel del resumen: el rango con cuántos préstamos y saldo tiene
class NivelMoraEntity extends RangoMoraEntity {
  final int indice;
  final int cantidad;
  final num saldo;

  const NivelMoraEntity({
    required this.indice,
    required this.cantidad,
    required this.saldo,
    required super.desde,
    required super.hasta,
    required super.colorHex,
    required super.etiqueta,
  });
}

class ResumenMoraEntity {
  final int total;
  final int clavos;
  final List<NivelMoraEntity> niveles;

  const ResumenMoraEntity({
    required this.total,
    required this.clavos,
    required this.niveles,
  });
}

/// Préstamo vencido con su cliente y nivel de atraso
class AtrasadoEntity {
  final String prestamoId;
  final num monto;
  final num totalPagar;
  final num saldo;
  final String fechaFin;
  final int diasAtraso;
  final NivelMoraEntity? nivel;
  final String clienteId;
  final String nombres;
  final String apellidos;
  final String cedula;
  final String telefono;
  final String estadoCliente;
  final String rutaNombre;

  const AtrasadoEntity({
    required this.prestamoId,
    required this.monto,
    required this.totalPagar,
    required this.saldo,
    required this.fechaFin,
    required this.diasAtraso,
    required this.nivel,
    required this.clienteId,
    required this.nombres,
    required this.apellidos,
    required this.cedula,
    required this.telefono,
    required this.estadoCliente,
    required this.rutaNombre,
  });

  bool get clavo => estadoCliente == 'CLAVO';
}

class AtrasadosPageEntity {
  final List<AtrasadoEntity> data;
  final ResumenMoraEntity resumen;
  final PaginationEntity pagination;

  const AtrasadosPageEntity({
    required this.data,
    required this.resumen,
    required this.pagination,
  });
}

/// "#EB5757" → Color; gris si no es válido
Color colorDesdeHex(String hex) {
  final limpio = hex.replaceFirst('#', '');
  final valor = int.tryParse(limpio, radix: 16);
  if (limpio.length != 6 || valor == null) return const Color(0xFF8A93A3);
  return Color(0xFF000000 | valor);
}

/// Color → "#RRGGBB"
String hexDesdeColor(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
