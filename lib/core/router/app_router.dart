import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/lugar_detail_screen.dart';
import '../../features/home/presentation/favorites_screen.dart';
import '../../features/home/presentation/main_layout.dart';
import '../../features/home/domain/lugar.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/events/presentation/event_detail_screen.dart';
import '../../features/events/domain/evento.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../core/theme/app_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authNotifier.isAuthenticated ? '/explore' : '/auth',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuth = authNotifier.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/auth');
      final isOnboarding = location.startsWith('/onboarding');

      // User just logged in but still on auth page → go to explore
      if (isAuth && isAuthRoute) return '/explore';

      // User signed out → send back to auth (allow /explore for guests)
      if (!isAuth && !isAuthRoute && !isOnboarding && location != '/explore') {
        return '/auth';
      }

      return null;
    },
    routes: [
      // Shell route for bottom nav tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/events',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EventsScreen()),
          ),
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MapScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Detail screens (pushed over nav)
      GoRoute(
        path: '/detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // Prefer pre-loaded Lugar via extra (from in-app navigation)
          final extra = state.extra;
          if (extra is Lugar) {
            return LugarDetailScreen(lugar: extra);
          }
          // Fallback: async loader for deep links
          final id = state.pathParameters['id']!;
          return _LugarDetailLoader(id: id);
        },
      ),
      GoRoute(
        path: '/event/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final evento = mockEventos.where((e) => e.id == id).firstOrNull;
          if (evento == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Evento no encontrado')),
            );
          }
          return EventDetailScreen(evento: evento);
        },
      ),

      // Search
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Profile sub-screens
      GoRoute(
        path: '/profile/favorites',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Auth
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});

/// Async wrapper that loads a Lugar by ID for deep-link navigation.
class _LugarDetailLoader extends ConsumerWidget {
  final String id;
  const _LugarDetailLoader({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLugar = ref.watch(lugarByIdProvider(id));

    return asyncLugar.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No se pudo cargar el lugar')),
      ),
      data: (lugar) {
        if (lugar == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Lugar no encontrado')),
          );
        }
        return LugarDetailScreen(lugar: lugar);
      },
    );
  }
}
