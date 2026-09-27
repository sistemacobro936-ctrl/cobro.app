import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/domain/entities/config_entity.dart';

/// Genera las fechas de pago de un préstamo según su frecuencia y los días
/// de cobro habilitados en la configuración del negocio (Shared.getConfig).
/// Extraído de PrestamoCubit para poder reutilizarlo (p. ej. en el reembolso)
/// sin depender del estado del cubit de creación de préstamos.
class FechasPagoUtil {
  FechasPagoUtil._();

  static List<DateTime> generar({
    required DateTime fechaInicial,
    required SCobroEntity periodo,
    required int cuotas,
  }) {
    final config = Shared.getConfig;
    if (config == null || cuotas <= 0) return [];

    final diasPago = config.diasCobro
        .where((e) => e.habilitado && e.diaSemana != null)
        .map((e) => e.diaSemana!)
        .toSet();

    if (diasPago.isEmpty) return [];

    final fechas = <DateTime>[];
    var fecha = fechaInicial;

    for (var i = 0; i < cuotas; i++) {
      fecha = _siguienteFecha(
        fechaActual: fecha,
        periodo: periodo,
        diasPago: diasPago,
      );
      fechas.add(fecha);
    }

    return fechas;
  }

  static DateTime _siguienteFecha({
    required DateTime fechaActual,
    required SCobroEntity periodo,
    required Set<int> diasPago,
  }) {
    final codigo = periodo.codigo?.toUpperCase();

    DateTime fecha;
    switch (codigo) {
      case 'DIARIO':
        fecha = fechaActual.add(const Duration(days: 1));
        break;
      case 'SEMANAL':
        fecha = fechaActual.add(const Duration(days: 7));
        break;
      case 'QUINCENAL':
        fecha = fechaActual.add(const Duration(days: 15));
        break;
      case 'MENSUAL':
        fecha = fechaActual.add(const Duration(days: 30));
        break;
      default:
        fecha = fechaActual.add(Duration(days: periodo.cantidadDias ?? 1));
    }

    while (!diasPago.contains(fecha.weekday)) {
      fecha = fecha.add(const Duration(days: 1));
    }

    return fecha;
  }
}
