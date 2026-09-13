class CrearClienteDto {
  final String? nombres;
  final String? apellidos;
  final String? cedula;
  final String? telefono;
  final String? whatsapp;
  final String? direccion;
  final String? rutaId;
  final String? descripcionDireccion;
  final String? barrio;
  final String? observacion;

  CrearClienteDto({
    this.nombres,
    this.apellidos,
    this.cedula,
    this.telefono,
    this.whatsapp,
    this.direccion,
    this.descripcionDireccion,
    this.rutaId,
    this.barrio,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "nombres": nombres,
      "apellidos": apellidos,
      "cedula": cedula,
      "telefono": telefono,
      "whatsapp": whatsapp,
      "direccion": direccion,
      "descripcionDireccion": descripcionDireccion,
      "rutaId": rutaId,
      "barrio": barrio,
      "observacion": observacion,
    };

    data.removeWhere(
      (key, value) => value == null || value.toString().trim().isEmpty,
    );

    return data;
  }
}
