import 'package:personal/src/domain/entities/movimientos_caja_entity.dart';

List<Map<String, dynamic>> _lista(dynamic value) =>
    ((value as List?) ?? []).cast<Map<String, dynamic>>();

DateTime? _fecha(dynamic value) => DateTime.tryParse('$value')?.toLocal();

List<PagoMovimientoEntity> _pagos(dynamic value) => _lista(value)
    .map(
      (e) => PagoMovimientoEntity(
        id: e['id'] ?? '',
        valor: e['valor'] ?? 0,
        fecha: _fecha(e['fecha']),
      ),
    )
    .toList();

class MovimientosCajaModel extends MovimientosCajaEntity {
  MovimientosCajaModel({
    required super.caja,
    required super.resumen,
    required super.inyeccionesCapital,
    required super.pagosDobles,
    required super.pagosMenores,
  });

  factory MovimientosCajaModel.fromJson(Map<String, dynamic> json) {
    final caja = (json['caja'] as Map<String, dynamic>?) ?? {};
    final resumen = (json['resumen'] as Map<String, dynamic>?) ?? {};

    return MovimientosCajaModel(
      caja: MovimientosCajaInfoEntity(
        id: caja['id'] ?? '',
        rutaId: caja['rutaId'] ?? '',
        rutaNombre: caja['rutaNombre'] ?? '',
        fechaOperacion: caja['fechaOperacion'] ?? '',
        estado: caja['estado'] ?? '',
      ),
      resumen: ResumenMovimientosEntity(
        cantidadInyecciones: resumen['cantidadInyecciones'] ?? 0,
        totalInyectado: resumen['totalInyectado'] ?? 0,
        cantidadPagosDobles: resumen['cantidadPagosDobles'] ?? 0,
        cantidadPagosMenores: resumen['cantidadPagosMenores'] ?? 0,
        faltanteTotal: resumen['faltanteTotal'] ?? 0,
      ),
      inyeccionesCapital: _lista(json['inyeccionesCapital'])
          .map(
            (e) => InyeccionCapitalEntity(
              id: e['id'] ?? '',
              valor: e['valor'] ?? 0,
              observacion: e['observacion'] ?? '',
              fecha: _fecha(e['fecha']),
            ),
          )
          .toList(),
      pagosDobles: _lista(json['pagosDobles'])
          .map(
            (e) => PagoDobleEntity(
              prestamoId: e['prestamoId'] ?? '',
              clienteNombre: e['clienteNombre'] ?? '',
              valorCuota: e['valorCuota'] ?? 0,
              valorPagado: e['valorPagado'] ?? 0,
              cantidadPagos: e['cantidadPagos'] ?? 0,
              fecha: _fecha(e['fecha']),
              pagos: _pagos(e['pagos']),
            ),
          )
          .toList(),
      pagosMenores: _lista(json['pagosMenores'])
          .map(
            (e) => PagoMenorEntity(
              prestamoId: e['prestamoId'] ?? '',
              clienteNombre: e['clienteNombre'] ?? '',
              valorCuota: e['valorCuota'] ?? 0,
              valorPagado: e['valorPagado'] ?? 0,
              cantidadPagos: e['cantidadPagos'] ?? 0,
              faltante: e['faltante'] ?? 0,
              fecha: _fecha(e['fecha']),
              pagos: _pagos(e['pagos']),
            ),
          )
          .toList(),
    );
  }
}
