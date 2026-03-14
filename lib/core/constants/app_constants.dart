/// App-wide constants.
///
/// Secrets are injected via `--dart-define` at build time.
/// For local development, create a `.env` file (see `.env.example`)
/// and pass them with:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=... \
///   --dart-define=SUPABASE_ANON_KEY=... \
///   --dart-define=MAPBOX_ACCESS_TOKEN=...
/// ```
class AppConstants {
  const AppConstants._();

  // ── Supabase (injected via --dart-define) ──────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // ── Mapbox (injected via --dart-define) ────────────────────
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  // ── Validation ─────────────────────────────────────────────
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasMapboxConfig => mapboxAccessToken.isNotEmpty;
}
