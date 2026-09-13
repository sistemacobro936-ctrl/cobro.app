import 'package:flutter/material.dart';

class StatusClienteView extends StatelessWidget {
  final bool active;
  const StatusClienteView({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
      final color = active ? const Color(0xFF4164E8) : const Color(0xFF8A93A3);

    final background = active
        ? const Color(0xFFEEF4FF)
        : const Color(0xFFF1F2F4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 4),

          Text(
            active ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}