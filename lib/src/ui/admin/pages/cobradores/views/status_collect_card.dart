import 'package:flutter/material.dart';

class StatusCollectCard extends StatelessWidget {
  final bool active;
  const StatusCollectCard({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
     
         final color = active ? const Color(0xFF4F7CFF) : const Color(0xFF9AA2AF);

     final background = active
        ? const Color(0xFFEEF4FF)
        : const Color(0xFFF1F2F4);

  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 4),

          Text(
            active ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}