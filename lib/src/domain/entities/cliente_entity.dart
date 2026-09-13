import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';

class ClienteEntity {
  final bool exito;
  final String msg;
  final List<DatumClEntity> data;
  final PaginationEntity? pagination;


  ClienteEntity({required this.exito, required this.msg, required this.data, this.pagination});
}

class DatumClEntity {
  final String id;
  final String nombres;
  final String rutaId;
  final String apellidos;
  final String cedula;
  final String telefono;
  final String whatsapp;
  final String direccion;
  final String descripcionDireccion;
  final String barrio;
  final String observacion;
  final String estado;
  final int totalPrestado;
  final List<DatumPEntity>? prestamos;

  DatumClEntity({
    required this.id,
    required this.nombres,
    required this.rutaId,
    required this.apellidos,
    required this.cedula,
    required this.telefono,
    required this.whatsapp,
    required this.direccion,
    required this.descripcionDireccion,
    required this.barrio,
    required this.observacion,
    required this.estado,
    required this.totalPrestado,
    this.prestamos,
  });
}

