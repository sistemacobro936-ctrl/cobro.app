class ServerExceptions implements Exception {
  final String? message;
  final String? stattusCode;

  /// Código de negocio que manda el backend en algunos errores
  /// (p. ej. `CLIENTE_EN_OTRO_NEGOCIO`)
  final String? codigo;

  ServerExceptions({
    this.message,
    this.stattusCode,
    this.codigo,
  });
}

class CacheExceptions implements Exception {
    final String? message;
  final String? stattusCode;

  CacheExceptions({
    this.message,
    this.stattusCode,
  });
}