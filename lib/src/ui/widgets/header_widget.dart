import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';

class HeaderWidget extends StatelessWidget {
  final Widget child;
  const HeaderWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
       width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: child,
    );
  }
}