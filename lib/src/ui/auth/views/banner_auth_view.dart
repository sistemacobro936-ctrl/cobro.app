import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class BannerAuthView extends StatelessWidget {
  const BannerAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.attach_money_rounded,
              size: 38,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'CobroAPP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Gestión de cobros y pagos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
