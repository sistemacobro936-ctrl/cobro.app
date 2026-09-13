import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: const Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 15, color: Color(0xFF687386)),
          SizedBox(width: 5),
          Text(
            'Filtrar',
            style: TextStyle(
              color: Color(0xFF687386),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}