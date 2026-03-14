import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import 'providers/notification_prefs_provider.dart';
import 'providers/profile_providers.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    final user = ref.watch(userProfileProvider);
    final iconColor = context.textSubtle;
    final subtitleColor = context.textSubtle;
    final dividerColor = context.dividerColor;

    return QshScaffoldBackground(
      appBar: AppBar(
        title: const GradientText('Configuración'),
        actions: const [
          AuthBrandLogo(maxWidth: 40, glowOpacity: 0, padding: EdgeInsets.zero),
          SizedBox(width: 8),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Notificaciones'),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.event,
            label: 'Eventos cercanos',
            subtitle: 'Recibe alertas de eventos a 1km de ti',
            value: prefs.eventos,
            onChanged: notifier.setEventos,
          ),
          _ToggleTile(
            icon: Icons.local_offer,
            label: 'Promociones',
            subtitle: 'Ofertas y descuentos de lugares',
            value: prefs.promociones,
            onChanged: notifier.setPromociones,
          ),
          _ToggleTile(
            icon: Icons.place,
            label: 'Nuevos lugares',
            subtitle: 'Cuando un lugar nuevo se une a KeHace',
            value: prefs.nuevosLugares,
            onChanged: notifier.setNuevosLugares,
          ),
          _ToggleTile(
            icon: Icons.auto_awesome,
            label: 'Recomendaciones personalizadas',
            subtitle: 'Sugerencias basadas en tus intereses',
            value: prefs.recomendaciones,
            onChanged: notifier.setRecomendaciones,
          ),
          const SizedBox(height: 28),

          _SectionTitle(title: 'General'),
          const SizedBox(height: 8),
          const _ThemeModeTile(),
          Divider(color: dividerColor),
          ListTile(
            leading: Icon(Icons.location_city, color: iconColor),
            title: const Text('Ciudad'),
            subtitle: Text(
              user?.ciudad ?? 'Medellín',
              style: TextStyle(color: subtitleColor),
            ),
            trailing: Icon(Icons.chevron_right, color: context.iconFaint),
            onTap: () {},
          ),
          Divider(color: dividerColor),

          const SizedBox(height: 28),
          _SectionTitle(title: 'Acerca de'),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: const Text('Versión'),
            subtitle: Text(
              '1.0.0 (build 1)',
              style: TextStyle(color: subtitleColor),
            ),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: iconColor),
            title: const Text('Términos y condiciones'),
            trailing: Icon(
              Icons.open_in_new,
              size: 18,
              color: context.iconFaint,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: iconColor),
            title: const Text('Política de privacidad'),
            trailing: Icon(
              Icons.open_in_new,
              size: 18,
              color: context.iconFaint,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 32),

          Center(
            child: TextButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: const Text('Eliminar cuenta'),
                    content: const Text(
                      '¿Estás seguro? Esta acción no se puede deshacer y perderás todos tus datos.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.delete_forever,
                color: AppTheme.error,
                size: 18,
              ),
              label: const Text(
                'Eliminar cuenta',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: AppTheme.primary),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(themeModeProvider.notifier);
    final pref = notifier.preference;
    final subtitleColor = context.textSubtle;

    final labels = {
      AppThemePreference.auto: 'Automático',
      AppThemePreference.light: 'Claro',
      AppThemePreference.dark: 'Oscuro',
    };

    final icons = {
      AppThemePreference.auto: Icons.brightness_auto,
      AppThemePreference.light: Icons.light_mode,
      AppThemePreference.dark: Icons.dark_mode,
    };

    return ListTile(
      leading: Icon(icons[pref], color: AppTheme.primary),
      title: const Text('Tema'),
      subtitle: Text(
        labels[pref]!,
        style: TextStyle(color: subtitleColor, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: context.iconFaint),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.iconFaint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                for (final option in AppThemePreference.values)
                  ListTile(
                    leading: Icon(
                      icons[option],
                      color: pref == option ? AppTheme.primary : null,
                    ),
                    title: Text(labels[option]!),
                    trailing: pref == option
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                    onTap: () {
                      notifier.setPreference(option);
                      Navigator.pop(context);
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = context.textSubtle;
    final subtitleColor = context.textSubtle;

    return SwitchListTile(
      secondary: Icon(icon, color: iconColor),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: subtitleColor, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppTheme.primary,
    );
  }
}
