import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum ContactAction { call, whatsapp }

class ContactUtil {
  static Future<void> open({
    required String telefono,
    required ContactAction action,
    String? mensaje,
  }) async {
    final numero = telefono.replaceAll(RegExp(r'[^0-9]'), '');

    if (numero.isEmpty) return;

    late final Uri uri;

    switch (action) {
      case ContactAction.call:
        uri = Uri(
          scheme: 'tel',
          path: numero,
        );
        break;

      case ContactAction.whatsapp:
        final numeroCompleto =
            numero.startsWith('57') ? numero : '57$numero';

        uri = Uri.https(
          'wa.me',
          '/$numeroCompleto',
          mensaje != null && mensaje.isNotEmpty
              ? {'text': mensaje}
              : null,
        );
        break;
    }

    try {
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      debugPrint('Abriendo $uri -> $result');
    } catch (e) {
      debugPrint('Error abriendo $uri: $e');
    }
  }
}