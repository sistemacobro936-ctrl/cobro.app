class AdministradoresEntity {
  final bool exito;
  final String msg;
  final List<DatumAdministradorEntity> data;

  AdministradoresEntity({
    required this.exito,
    required this.msg,
    required this.data,
  });
}

class DatumAdministradorEntity {
  final String id;
  final String nombre;
  final String apellido;
  final String documento;
  final String telefono;
  final String email;
  final String estado;

  DatumAdministradorEntity({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.telefono,
    required this.email,
    required this.estado,
  });
}
