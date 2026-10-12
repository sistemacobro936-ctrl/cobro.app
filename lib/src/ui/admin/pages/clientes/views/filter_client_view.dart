import 'package:flutter/material.dart';

/// Botón "Filtrar" que deja elegir el estado de los clientes listados
class FilterClientView extends StatelessWidget {
  const FilterClientView({
    super.key,
    required this.estado,
    required this.onSelected,
  });

  /// Estado seleccionado; '' = todos
  final String estado;
  final ValueChanged<String> onSelected;

  static const opciones = {
    '': 'Todos',
    'ACTIVO': 'Activos',
    'PENDIENTE_APROBACION': 'Por aprobar',
    'INACTIVO': 'Inactivos',
  };

  @override
  Widget build(BuildContext context) {
    final activo = estado.isNotEmpty;
    final color = activo ? const Color(0xFF4164E8) : const Color(0xFF687386);

    return PopupMenuButton<String>(
      initialValue: estado,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final o in opciones.entries)
          PopupMenuItem(value: o.key, child: Text(o.value)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFFEEF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              activo ? opciones[estado] ?? estado : 'Filtrar',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
