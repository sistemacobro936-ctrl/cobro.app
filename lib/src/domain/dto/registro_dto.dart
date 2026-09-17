import 'package:personal/src/domain/dto/administrador_dto.dart';
import 'package:personal/src/domain/dto/registro_negocio_dto.dart';

class RegistroDto {
  final RegistroNegocioDto negocio;
  final AdministradorDto admin;

  RegistroDto({required this.negocio, required this.admin});

  Map<String, dynamic> toJson() => {
    "negocio": negocio.toJson(),
    "admin": admin.toJson(),
  };
}
