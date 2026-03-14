import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/lugar.dart';

// Provider para la categoría seleccionada
final selectedCategoryProvider = StateProvider<String>(
  (ref) => 'Toda la ciudad',
);

// ── Supabase data ──────────────────────────────────────────

/// Fetches all lugares from Supabase; falls back to mockLugares on error.
final lugaresProvider = FutureProvider<List<Lugar>>((ref) async {
  try {
    final data = await Supabase.instance.client
        .from('lugares')
        .select()
        .not('lat', 'is', null)
        .not('lng', 'is', null)
        .limit(200);

    if (data.isEmpty) return mockLugares;

    return data
        .map<Lugar>((json) => Lugar.fromSupabase(json))
        .where((l) => l.latitud != 0.0 || l.longitud != 0.0)
        .toList();
  } catch (e) {
    debugPrint('Error fetching lugares: $e');
    return mockLugares;
  }
});

/// Sync convenience — returns loaded lugares or empty list while loading.
final lugaresListProvider = Provider<List<Lugar>>((ref) {
  return ref.watch(lugaresProvider).valueOrNull ?? [];
});

// ── Filtered list ──────────────────────────────────────────

final filteredLugaresProvider = Provider<List<Lugar>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final lugares = ref.watch(lugaresListProvider);

  // While still loading, fall back to mock data for responsive UI
  final source = lugares.isEmpty ? mockLugares : lugares;

  if (category == 'Toda la ciudad') {
    return source;
  }

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

  // 2. Check mock data
  final mock = mockLugares.where((l) => l.id == id).firstOrNull;
  if (mock != null) return mock;

  // 3. Direct query to Supabase
  try {
    final data = await Supabase.instance.client
        .from('lugares')
        .select()
        .eq('id', int.parse(id))
        .maybeSingle();

    if (data != null) return Lugar.fromSupabase(data);
  } catch (e) {
    debugPrint('Error fetching lugar $id: $e');
  }

  return null;
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
