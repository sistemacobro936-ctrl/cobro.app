import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';

/// Fila de un evento de actividad (pago, no pago, préstamo o gasto)
class ActividadItem extends StatelessWidget {
  final ActividadEntity actividad;

  const ActividadItem({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final a = actividad;
    final valor = MoneyUtil.format(a.valor);

    final IconData icon;
    final Color color;
    final String title;
    final String value;

    switch (a.tipo) {
      case TipoActividad.pago:
        icon = Icons.payments_outlined;
        color = Colors.green;
        title = 'Pago recibido';
        value = '+$valor';
      case TipoActividad.noPago:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        title = a.motivo == null || a.motivo!.isEmpty
            ? 'No pagó'
            : 'No pagó · ${MotivoNoPago.labelDe(a.motivo!)}';
        value = valor;
      case TipoActividad.prestamo:
        icon = Icons.request_quote_outlined;
        color = AppTheme.primaryColor;
        title = 'Préstamo nuevo';
        value = valor;
      case TipoActividad.gasto:
        icon = Icons.receipt_long_outlined;
        color = Colors.redAccent;
        title = 'Gasto';
        value = '-$valor';
      case TipoActividad.otro:
        icon = Icons.info_outline_rounded;
        color = Colors.grey;
        title = a.tipoCodigo.isEmpty ? 'Movimiento' : a.tipoCodigo;
        value = valor;
    }

    // El gasto no tiene cliente: se muestra el concepto en su lugar
    final principal = a.tipo == TipoActividad.gasto
        ? a.concepto
        : a.clienteNombre;
    final subtitle = [
      if (principal != null && principal.isNotEmpty) principal,
      if (a.rutaNombre.isNotEmpty) a.rutaNombre,
    ].join(' • ');

    final hora = a.fecha == null
        ? null
        : '${a.fecha!.hour.toString().padLeft(2, '0')}:'
              '${a.fecha!.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                 
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF8A93A3), ),
              ),

              if (a.tipo == TipoActividad.noPago && a.fechaPromesa != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Promete pagar: ${DateUtil.formatDate(a.fechaPromesa!)}',
                    style: const TextStyle(
                      color: Color(0xFF8A93A3),
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (hora != null) ...[
              const SizedBox(height: 3),
              Text(
                hora,
                style: const TextStyle(color: Color(0xFFB0B6C0), fontSize: 11),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
