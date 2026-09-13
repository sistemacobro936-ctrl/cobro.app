class CajaDto {
  final String? rutaId;

  final int? montoInicial;
  
  final String? fechaApertura;

  final int? montoReal;

  final int? diferencia;

  final String? observacion;

  CajaDto({
     this.rutaId,
    this.montoInicial,
    this.fechaApertura,
    this.montoReal,
    this.diferencia,
    this.observacion,
  });
  Map<String, dynamic> toJson() {
    return {
      if (rutaId != null) "rutaId": rutaId,
      if (montoInicial != null) "montoInicial": montoInicial,
      if (fechaApertura != null) "fechaApertura": fechaApertura,
      if (montoReal != null) "montoReal": montoReal,
      if (diferencia != null) "diferencia": diferencia,
      if (observacion != null) "observacion": observacion,
    };
  }
}
