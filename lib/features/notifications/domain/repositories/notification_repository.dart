import '../../../../core/errors/result.dart';
import '../app_notification.dart';

abstract class NotificationRepository {
  Future<Result<List<AppNotification>>> getNotifications();
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
}
