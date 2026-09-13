import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/ui/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initDep();

  await initializeDateFormatting('es_ES');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,

      locale: const Locale('es', 'CO'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('es', 'CO'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),

      home: const AuthPage(),
    );
  }
}