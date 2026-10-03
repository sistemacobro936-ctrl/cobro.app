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

/// Inyecciones/retiros de capital y retiros de seguro comparten esta forma
List<InyeccionCapitalEntity> _capitalItems(dynamic value) => _lista(value)
    .map(
      (e) => InyeccionCapitalEntity(
        id: e['id'] ?? '',
        valor: e['valor'] ?? 0,
        observacion: e['observacion'] ?? '',
        fecha: _fecha(e['fecha']),
      ),
    )
    .toList();

/// Préstamos nuevos y reembolsos del día comparten esta forma; los
/// reembolsos traen además prestamoAnteriorId
List<PrestamoDelDiaEntity> _prestamos(dynamic value) => _lista(value)
    .map(
      (e) => PrestamoDelDiaEntity(
        id: e['id'] ?? '',
        clienteNombre: e['clienteNombre'] ?? '',
        clienteCedula: e['clienteCedula'] ?? '',
        monto: e['monto'] ?? 0,
        valorSeguro: e['valorSeguro'] ?? 0,
        valorCuota: e['valorCuota'] ?? 0,
        numeroCuotas: e['numeroCuotas'] ?? 0,
        frecuencia: e['frecuencia'] ?? '',
        estado: e['estado'] ?? '',
        fecha: _fecha(e['fecha']),
        prestamoAnteriorId: e['prestamoAnteriorId'],
      ),
    )
    .toList();

class MovimientosCajaModel extends MovimientosCajaEntity {
  MovimientosCajaModel({
    required super.caja,
    required super.resumen,
    required super.inyeccionesCapital,
    required super.retirosCapital,
    required super.retirosSeguro,
    required super.pagosDobles,
    required super.pagosMenores,
    required super.prestamosDelDia,
    required super.reembolsosDelDia,
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
        cantidadRetirosCapital: resumen['cantidadRetirosCapital'] ?? 0,
        totalRetiradoCapital: resumen['totalRetiradoCapital'] ?? 0,
        cantidadRetirosSeguro: resumen['cantidadRetirosSeguro'] ?? 0,
        totalRetiradoSeguro: resumen['totalRetiradoSeguro'] ?? 0,
        cantidadPagosDobles: resumen['cantidadPagosDobles'] ?? 0,
        cantidadPagosMenores: resumen['cantidadPagosMenores'] ?? 0,
        faltanteTotal: resumen['faltanteTotal'] ?? 0,
        cantidadPrestamos: resumen['cantidadPrestamos'] ?? 0,
        totalPrestado: resumen['totalPrestado'] ?? 0,
        cantidadReembolsos: resumen['cantidadReembolsos'] ?? 0,
        totalReembolsado: resumen['totalReembolsado'] ?? 0,
      ),
      inyeccionesCapital: _capitalItems(json['inyeccionesCapital']),
      retirosCapital: _capitalItems(json['retirosCapital']),
      retirosSeguro: _capitalItems(json['retirosSeguro']),
      pagosDobles: _lista(json['pagosDobles'])
          .map(
            (e) => PagoDobleEntity(
              prestamoId: e['prestamoId'] ?? '',
              clienteNombre: e['clienteNombre'] ?? '',
              clienteCedula: e['clienteCedula'] ?? '',
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
              clienteCedula: e['clienteCedula'] ?? '',
              valorCuota: e['valorCuota'] ?? 0,
              valorPagado: e['valorPagado'] ?? 0,
              cantidadPagos: e['cantidadPagos'] ?? 0,
              faltante: e['faltante'] ?? 0,
              fecha: _fecha(e['fecha']),
              pagos: _pagos(e['pagos']),
            ),
          )
          .toList(),
      prestamosDelDia: _prestamos(json['prestamosDelDia']),
      reembolsosDelDia: _prestamos(json['reembolsosDelDia']),
    );
  }
}
