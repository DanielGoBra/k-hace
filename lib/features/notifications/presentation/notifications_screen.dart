import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/qsh_empty_state.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/app_notification.dart';
import 'providers/notifications_providers.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return QshScaffoldBackground(
      appBar: AppBar(
        title: const GradientText('Notificaciones'),
        actions: [
          const AuthBrandLogo(
            maxWidth: 40,
            glowOpacity: 0,
            padding: EdgeInsets.zero,
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('Marcar todas'),
            ),
        ],
      ),
      child: notifications.isEmpty
          ? const QshEmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No tienes notificaciones',
              subtitle: 'Cuando haya algo nuevo te avisaremos.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => ref
                      .read(notificationsProvider.notifier)
                      .dismiss(notification.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: AppTheme.error.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.error,
                    ),
                  ),
                  child: _NotificationTile(
                    notification: notification,
                    onTap: () {
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(notification.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationTile({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _typeColor(notification.tipo).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _typeIcon(notification.tipo),
          color: _typeColor(notification.tipo),
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              notification.titulo,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: notification.leida
                    ? FontWeight.normal
                    : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (!notification.leida)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.cuerpo,
            style: TextStyle(color: context.textSubtle, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            _timeAgo(notification.fechaCreacion),
            style: TextStyle(color: context.textFaint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(NotificationType tipo) {
    switch (tipo) {
      case NotificationType.eventoCercano:
        return Icons.event;
      case NotificationType.nuevoLugar:
        return Icons.place;
      case NotificationType.promo:
        return Icons.local_offer;
      case NotificationType.sistema:
        return Icons.info_outline;
    }
  }

  Color _typeColor(NotificationType tipo) {
    switch (tipo) {
      case NotificationType.eventoCercano:
        return AppTheme.primary;
      case NotificationType.nuevoLugar:
        return AppTheme.success;
      case NotificationType.promo:
        return AppTheme.warning;
      case NotificationType.sistema:
        return AppTheme.textSecondary;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }
}
