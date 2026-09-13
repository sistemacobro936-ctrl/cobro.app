class ServerExceptions implements Exception {
  final String? message;
  final String? stattusCode;

  ServerExceptions({
    this.message,
    this.stattusCode,
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