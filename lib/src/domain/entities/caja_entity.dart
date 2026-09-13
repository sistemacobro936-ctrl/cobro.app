import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/entities/pago_entity.dart';

class CajaEntity {
    final bool exito;
    final String msg;
    final List<DatumCajaEntity>? data;

    CajaEntity({
        required this.exito,
        required this.msg,
         this.data,
    });

}

class DatumCajaEntity {
    final String id;
    final String rutaId;
    final String abiertaPorId;
    final int montoInicial;
    final int montoPrestado;
    final int cobroEsperado;
    final int gastos;
    final int cobrado;
    final int montoEsperado;
    final int interesGenerado;
    final int saldoSeguros;
    final dynamic montoReal;
    final dynamic diferencia;
    final String estado;
    final DateTime fechaApertura;
    final dynamic fechaCierre;
    final DateTime createdAt;
    final DateTime updatedAt;
    final DateTime fechaOperacion;
    final List<PagoEntity>? pagos;
    final List<GastoElementEntity>? gastosCaja;
    final PaginationEntity? pagination;

    DatumCajaEntity({
        required this.id,
        required this.rutaId,
        required this.abiertaPorId,
        required this.cobrado,
        required this.montoInicial,
        required this.montoEsperado,
        required this.cobroEsperado,
        required this.gastos,
        required this.montoReal,
        required this.diferencia,
        required this.estado,
        required this.fechaApertura,
        required this.fechaCierre,
        required this.createdAt,
        required this.updatedAt,
        required this.fechaOperacion,
        required this.montoPrestado,
        required this.interesGenerado,
        required this.saldoSeguros,
        this.pagos,
        this.gastosCaja,
        this.pagination
    });

}
