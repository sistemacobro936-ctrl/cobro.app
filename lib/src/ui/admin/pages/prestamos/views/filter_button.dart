import 'package:flutter/material.dart';

/// Botón "Filtrar" que deja elegir el estado de los préstamos listados
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.estado,
    required this.onSelected,
  });

  final String estado;
  final ValueChanged<String> onSelected;

  static const opciones = {
    'ACTIVO': 'Activos',
    'PAGADO': 'Pagados',
    'CANCELADO': 'Cancelados',
    'TODOS': 'Todos',
  };

  @override
  Widget build(BuildContext context) {
    // Activos es la vista por defecto; otro estado se resalta
    final resaltado = estado != 'ACTIVO';
    final color =
        resaltado ? const Color(0xFF4164E8) : const Color(0xFF687386);

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
          color: resaltado ? const Color(0xFFEEF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              opciones[estado] ?? 'Filtrar',
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
