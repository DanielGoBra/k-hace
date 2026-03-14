import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import '../../home/presentation/providers/favorites_provider.dart';
import '../presentation/providers/profile_providers.dart';
import '../../events/presentation/providers/events_providers.dart';
import '../../../shared/widgets/gradient_text.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return _buildUnauthenticated(context, ref);
    }

    final favoritesCount = ref.watch(favoritesProvider).length;
    final savedEventsCount = ref.watch(savedEventsProvider).length;
    final subtleColor = context.textSubtle;

    return QshScaffoldBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ── Avatar with edit button ──
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: user?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user!.avatarUrl!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user?.iniciales ?? '',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => context.push('/profile/edit'),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GradientText(
                user?.nombre ?? '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: subtleColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user?.ciudad ?? '',
                    style: TextStyle(color: subtleColor, fontSize: 13),
                  ),
                ],
              ),

              // ── Interests chips ──
              if (user != null && user.intereses.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: user.intereses.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // ── Stats ──
              Row(
                children: [
                  _StatCard(
                    count: favoritesCount,
                    label: 'Planes\nguardados',
                    icon: Icons.favorite,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    count: savedEventsCount,
                    label: 'Eventos\nguardados',
                    icon: Icons.event,
                    color: AppTheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Menu items ──
              _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Editar perfil',
                onTap: () => context.push('/profile/edit'),
              ),
              _MenuItem(
                icon: Icons.favorite_outline,
                label: 'Mis Planes',
                onTap: () => context.push('/profile/favorites'),
              ),
              _MenuItem(
                icon: Icons.event_outlined,
                label: 'Mis Eventos',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notificaciones',
                onTap: () => context.push('/notifications'),
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                onTap: () => context.push('/profile/settings'),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                icon: Icons.logout,
                label: 'Cerrar sesión',
                isDestructive: true,
                onTap: () async {
                  await ref.read(userProfileProvider.notifier).logout();
                  if (context.mounted) context.go('/auth');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticated(BuildContext context, WidgetRef ref) {
    return QshScaffoldBackground(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),
                GradientText(
                  'Tu perfil',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Inicia sesión para guardar tus planes favoritos y no perderte ningún evento.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/auth'),
                    child: const Text('INICIAR SESIÓN'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/auth'),
                    child: const Text('CREAR CUENTA'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = context.textSubtle;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(color: labelColor, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestructive ? AppTheme.error : context.textPrimary;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: baseColor.withValues(alpha: 0.7)),
      title: Text(label, style: TextStyle(color: baseColor, fontSize: 15)),
      trailing: Icon(
        Icons.chevron_right,
        color: baseColor.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
