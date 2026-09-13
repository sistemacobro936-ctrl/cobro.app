import 'package:flutter/material.dart';

class SectionHeaderCView extends StatelessWidget {
  const SectionHeaderCView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Cobradores',
            style: TextStyle(
              color: Color(0xFF1D2433),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: .05)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 16,
                color: Color(0xFF687386),
              ),
              SizedBox(width: 5),
              Text(
                'Filtrar',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF687386),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  
  }
}