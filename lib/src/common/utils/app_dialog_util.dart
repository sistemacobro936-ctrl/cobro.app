import 'package:flutter/material.dart';

class AppDialogUtil {
  AppDialogUtil._();

  static Future<void> error(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String buttonText = 'Aceptar',
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      title: title,
      message: message,
      icon: Icons.error_outline,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  static Future<void> success(
    BuildContext context, {
    String title = '¡Éxito!',
    required String message,
    String buttonText = 'Aceptar',
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  static Future<void> info(
    BuildContext context, {
    String title = 'Información',
    required String message,
    String buttonText = 'Aceptar',
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      title: title,
      message: message,
      icon: Icons.info_outline,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required String buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            12,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
              ),

              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    onPressed?.call();
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}