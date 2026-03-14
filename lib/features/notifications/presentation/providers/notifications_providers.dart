import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_notification.dart';

final notificationsProvider = StateNotifierProvider<
    NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(List.from(mockNotifications));

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(leida: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(leida: true)];
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.leida).length;
});
