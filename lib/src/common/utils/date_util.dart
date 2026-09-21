class DateUtil {
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static const _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _diasLargos = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  /// Nombre del día de la semana: Lun / Lunes
  static String nombreDia(DateTime date, {bool corto = false}) =>
      (corto ? _diasCortos : _diasLargos)[date.weekday - 1];

  /// Fecha para mostrar al usuario (solo lectura): Lun 21-09-2026
  static String formatLectura(DateTime date) {
    return '${nombreDia(date, corto: true)} '
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year.toString().padLeft(4, '0')}';
  }
}
