import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Mapbox ──────────────────────────────────────────────────
  final supportsNativeMapbox =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (AppConstants.hasMapboxConfig && supportsNativeMapbox) {
    try {
      MapboxOptions.setAccessToken(AppConstants.mapboxAccessToken);
    } catch (e) {
      debugPrint('Mapbox initialization skipped: $e');
    }
  } else if (!AppConstants.hasMapboxConfig) {
    debugPrint(
      '\u26A0 MAPBOX_ACCESS_TOKEN not set. '
      'Pass it via --dart-define=MAPBOX_ACCESS_TOKEN=...',
    );
  }

  // ── Supabase ────────────────────────────────────────────────
  if (AppConstants.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  } else {
    debugPrint(
      '\u26A0 SUPABASE_URL / SUPABASE_ANON_KEY not set. '
      'Pass them via --dart-define.',
    );
  }

  runApp(const ProviderScope(child: QueSeHaceApp()));
}

class QueSeHaceApp extends ConsumerWidget {
  const QueSeHaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: '¡K hace!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
