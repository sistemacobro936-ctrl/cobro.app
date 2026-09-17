class AdministradorDto {
  final String nombre;
  final String apellido;
  final String documento;
  final String telefono;
  final String email;
  final String username;
  final String password;

  AdministradorDto({
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.telefono,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "apellido": apellido,
    "documento": documento,
    "telefono": telefono,
    "email": email,
    "username": username,
    "password": password,
  };
}
