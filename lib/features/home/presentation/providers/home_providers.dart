import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/lugar.dart';

// Provider para la categoría seleccionada
final selectedCategoryProvider = StateProvider<String>(
  (ref) => 'Toda la ciudad',
);

// ── All lugares (from repository) ────────────────────────────

final lugaresProvider = FutureProvider<List<Lugar>>((ref) async {
  final repo = ref.read(lugarRepositoryProvider);
  final result = await repo.getLugares();
  return result.valueOrNull ?? [];
});

/// Sync convenience — returns loaded lugares or empty list while loading.
final lugaresListProvider = Provider<List<Lugar>>((ref) {
  return ref.watch(lugaresProvider).valueOrNull ?? [];
});

// ── Filtered list ──────────────────────────────────────────

final filteredLugaresProvider = Provider<List<Lugar>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final lugares = ref.watch(lugaresListProvider);

  // While loading, fall back to mock data for responsive UI
  final source = lugares.isEmpty ? mockLugares : lugares;

  if (category == 'Toda la ciudad') return source;

  return source.where((lugar) => lugar.categoria == category).toList();
});

// ── Single lugar by ID ─────────────────────────────────────

final lugarByIdProvider = FutureProvider.family<Lugar?, String>((
  ref,
  id,
) async {
  // 1. Check in-memory cache first
  final cached = ref.read(lugaresListProvider);
  final found = cached.where((l) => l.id == id).firstOrNull;
  if (found != null) return found;

  // 2. Query repository
  final repo = ref.read(lugarRepositoryProvider);
  final result = await repo.getLugarById(id);
  return result.valueOrNull;
});

// ── Recommended for user (based on interests) ────────────

final recommendedLugaresProvider = Provider<List<Lugar>>((ref) {
  final user = ref.watch(userProfileProvider);
  final lugares = ref.watch(lugaresListProvider);

  if (user == null || user.intereses.isEmpty) return [];

  final source = lugares.isEmpty ? mockLugares : lugares;
  return source
      .where((lugar) => user.intereses.contains(lugar.categoria))
      .toList();
});
