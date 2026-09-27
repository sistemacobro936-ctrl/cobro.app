import 'package:flutter/material.dart';

/// Paleta de la app. Referencia: apps fintech/de préstamos usan azules
/// "navy" oscuros como color primario (transmiten seguridad/confianza),
/// reservando verde para pagos/estados positivos y un tono cálido para
/// alertas de mora — ver fuentes en la respuesta que acompaña este cambio.
class AppTheme {
  AppTheme._();

  /// Azul "navy" de confianza — reemplaza el Colors.blue genérico anterior.
  static const Color primaryColor = Color(0xFF123A63);

  /// Tono más oscuro de la misma familia, para fondos/estados presionados.
  static const Color primaryDark = Color(0xFF0B1F3B);

  /// Tono más claro, para acentos y gradientes.
  static const Color primaryLight = Color(0xFF2F5D8C);

  /// Verde de pagos/estados positivos ("Vault Green").
  static const Color successColor = Color(0xFF1F6F54);
  static const Color successLight = Color(0xFF5FB88A);

  /// Rojo vinotinto para mora/alertas ("Burgundy Benchmark"): menos
  /// agresivo que un rojo puro, mantiene el tono serio del resto de la app.
  static const Color dangerColor = Color(0xFF9F2D45);
}
