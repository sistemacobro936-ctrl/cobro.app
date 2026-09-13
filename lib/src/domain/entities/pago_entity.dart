class PagoEntity {
  final String id;
  final String prestamoId;
  final String registradoPorId;
  final num valor;
  final String estado;
  final DateTime? fechaReversion;
  final DateTime? fechaPago;
  final String? usuarioReversionId;
  final String? motivoReversion;
  final DateTime createdAt;
  final DateTime updatedAt;

  PagoEntity({
    required this.id,
    required this.prestamoId,
    required this.registradoPorId,
    required this.valor,
    required this.estado,
    this.fechaReversion,
    this.fechaPago,
    this.usuarioReversionId,
    this.motivoReversion,
    required this.createdAt,
    required this.updatedAt,
  });
}