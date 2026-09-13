class UpdateUtil {
  static String? valorModificado(
    String? original,
    String? nuevo,
  ) {
    final valorOriginal = original?.trim();
    final valorNuevo = nuevo?.trim();

    if (valorOriginal == valorNuevo) {
      return null;
    }

    return valorNuevo;
  }
}