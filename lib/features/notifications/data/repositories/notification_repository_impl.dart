import '../../../../core/errors/result.dart';
import '../../domain/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource _local;
  final Set<String> _readIds = {};

  NotificationRepositoryImpl({required NotificationLocalDatasource local})
      : _local = local;

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    final notifications = _local.getNotifications().map((n) {
      if (_readIds.contains(n.id)) return n.copyWith(leida: true);
      return n;
    }).toList();
    return Success(notifications);
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    _readIds.add(id);
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    final all = _local.getNotifications();
    for (final n in all) {
      _readIds.add(n.id);
    }
    return const Success(null);
  }
}
