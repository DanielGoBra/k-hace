import 'package:flutter/material.dart';
import 'app_constants.dart';

void main() {
  // Valida que todos los secretos necesarios estén disponibles antes de
  // inicializar la app. Falla rápido y con mensaje claro.
  AppConstants.validateSecrets();

  runApp(const KHaceApp());
}

class KHaceApp extends StatelessWidget {
  const KHaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('k-hace 🚀'),
        ),
      ),
    );
  }
}
