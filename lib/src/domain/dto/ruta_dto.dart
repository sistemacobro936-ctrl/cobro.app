class RutaDto {
  final String? nombre;
  final String? descripcion;
  final String? cobradorId;
  final bool? habilitada;
  final int? capital;

  RutaDto({
    this.nombre,
    this.descripcion,
    this.cobradorId,
    this.habilitada,
    this.capital,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (nombre != null) {
      data['nombre'] = nombre;
    }
    if (descripcion != null) {
      data['descripcion'] = descripcion;
    }
      data['cobradorId'] = cobradorId;
    
    if (habilitada != null) {
      data['habilitada'] = habilitada;
    }
    if (capital != null) {
      data['capital'] = capital;
    }
    return data;
  }
}
