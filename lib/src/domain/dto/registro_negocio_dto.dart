class RegistroNegocioDto {
  final String nombre;
  final String documento;
  final String telefono;
  final String direccion;

  RegistroNegocioDto({
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.direccion,
  });

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "documento": documento,
    "telefono": telefono,
    "direccion": direccion,
  };
}
