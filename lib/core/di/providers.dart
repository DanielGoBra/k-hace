import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/events/data/datasources/evento_local_datasource.dart';
import '../../features/events/data/repositories/evento_repository_impl.dart';
import '../../features/events/domain/repositories/evento_repository.dart';
import '../../features/home/data/datasources/lugar_local_datasource.dart';
import '../../features/home/data/repositories/lugar_repository_impl.dart';
import '../../features/home/domain/repositories/lugar_repository.dart';
import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../constants/app_constants.dart';

// ── Supabase client ──────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!AppConstants.hasSupabaseConfig) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

// ── Datasources ──────────────────────────────────────────────────────────────

final lugarLocalDatasourceProvider = Provider<LugarLocalDatasource>(
  (ref) => LugarLocalDatasource(),
);

final eventoLocalDatasourceProvider = Provider<EventoLocalDatasource>(
  (ref) => EventoLocalDatasource(),
);

final notificationLocalDatasourceProvider =
    Provider<NotificationLocalDatasource>(
  (ref) => NotificationLocalDatasource(),
);

// ── Repositories ─────────────────────────────────────────────────────────────

final lugarRepositoryProvider = Provider<LugarRepository>((ref) {
  return LugarRepositoryImpl(
    local: ref.read(lugarLocalDatasourceProvider),
    supabase: ref.read(supabaseClientProvider),
  );
});

final eventoRepositoryProvider = Provider<EventoRepository>((ref) {
  return EventoRepositoryImpl(
    local: ref.read(eventoLocalDatasourceProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    local: ref.read(notificationLocalDatasourceProvider),
  );
});
