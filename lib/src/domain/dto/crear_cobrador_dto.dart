class CrearCobradorDto {
  final String? nombre;
  final String? apellido;
  final String? documento;
  final String? telefono;
  final String? username;
  final String? password;

  CrearCobradorDto({
    this.nombre,
    this.apellido,
    this.documento,
    this.telefono,
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "nombre": nombre,
      "apellido": apellido,
      "documento": documento,
      "telefono": telefono,
      "username": username,
      "password": password,
    };
    data.removeWhere(
      (key, value) => value == null || value.toString().trim().isEmpty,
    );

    return data;
  }
}
