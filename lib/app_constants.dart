// Constantes de la aplicación.
// Los valores se inyectan en tiempo de compilación mediante --dart-define.
// NUNCA hardcodees API keys aquí.

class AppConstants {
  AppConstants._();

  // ── Firebase ────────────────────────────────────────────────────────────────
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  // ── Google Maps ─────────────────────────────────────────────────────────────
  static const String mapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: '',
  );

  // ── App info ─────────────────────────────────────────────────────────────────
  static const String appName = 'k-hace';

  // ── Validación en tiempo de ejecución ────────────────────────────────────────
  /// Lanza [StateError] si algún secreto obligatorio está vacío.
  static void validateSecrets() {
    const required = {
      'FIREBASE_API_KEY': firebaseApiKey,
      'FIREBASE_PROJECT_ID': firebaseProjectId,
      'MAPS_API_KEY': mapsApiKey,
    };

    final missing = required.entries
        .where((e) => e.value.isEmpty)
        .map((e) => e.key)
        .toList();

    if (missing.isNotEmpty) {
      throw StateError(
        'Faltan variables de entorno obligatorias: ${missing.join(', ')}.\n'
        'Ejecuta la app con scripts/run_dev.sh o proporciona --dart-define.',
      );
    }
  }
}
