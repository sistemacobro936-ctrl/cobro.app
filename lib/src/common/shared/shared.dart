import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';
import 'package:personal/src/domain/entities/config_entity.dart'
    show DataConEntity;
import 'package:personal/src/domain/entities/ruta_entity.dart';

class Shared {
  static DataConEntity? _config;
  static List<DatumCEntity>? _cobradores;
  static List<DatumREntity>? _rutas;
  static String _idCliente = "";
  static List<DatumClEntity>? _clientes;
  static set setConfig(DataConEntity c) {
    _config = c;
  }

  static set setCobradores(List<DatumCEntity> c) {
    _cobradores = c;
  }

  static set setRutas(List<DatumREntity> r) {
    _rutas = r;
  }

  static set setClientes(List<DatumClEntity> c) {
    _clientes = c;
  }

  static set setIdCliente(String id) {
    _idCliente = id;
  }

  static DataConEntity? get getConfig => _config;
  static List<DatumCEntity>? get getCobradores => _cobradores;
  static List<DatumREntity>? get getRutas => _rutas;
  static String get getIdClient => _idCliente;
  static List<DatumClEntity>? get getClientes => _clientes;
}
