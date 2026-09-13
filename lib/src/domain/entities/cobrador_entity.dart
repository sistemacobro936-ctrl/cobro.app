import 'package:personal/src/domain/entities/ruta_entity.dart';

class CobradorEntity {
    final bool exito;
    final String msg;
    final List<DatumCEntity> data;

    CobradorEntity({
        required this.exito,
        required this.msg,
        required this.data,
    });

}

class DatumCEntity {
    final String id;
    final String nombre;
    final String apellido;
    final String documento;
    final String telefono;
    final String email;
    final String estado;
    final List<DatumREntity> rutas;

    DatumCEntity({
        required this.id,
        required this.nombre,
        required this.apellido,
        required this.documento,
        required this.telefono,
        required this.email,
        required this.estado,
        required this.rutas,
    });

}
