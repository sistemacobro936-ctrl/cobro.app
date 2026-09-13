import 'package:flutter/material.dart';

class SearPView extends StatelessWidget {
  const SearPView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Buscar cliente o cédula...',
          hintStyle: TextStyle(color: Color(0xFF9AA2AF), fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF6F7888)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}