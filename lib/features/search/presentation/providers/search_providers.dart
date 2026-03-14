import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/lugar.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../events/domain/evento.dart';
import '../../domain/search_result.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return [];

  final lugares = ref.watch(lugaresListProvider);
  final source = lugares.isEmpty ? mockLugares : lugares;

  final lugarResults = source
      .where(
        (l) =>
            l.nombre.toLowerCase().contains(query) ||
            l.categoria.toLowerCase().contains(query) ||
            l.tags.any((t) => t.toLowerCase().contains(query)) ||
            l.ubicacion.toLowerCase().contains(query),
      )
      .map((l) => SearchResult.fromLugar(l));

  final eventoResults = mockEventos
      .where(
        (e) =>
            e.nombre.toLowerCase().contains(query) ||
            e.categoria.toLowerCase().contains(query) ||
            e.lugarNombre.toLowerCase().contains(query),
      )
      .map((e) => SearchResult.fromEvento(e));

  final results = [...lugarResults, ...eventoResults];

  // Sort: Pro places first
  results.sort((a, b) {
    if (a.tipo == SearchResultType.lugar && b.tipo == SearchResultType.lugar) {
      final aPriority = a.lugar!.planTipo == PlanTipo.pro ? 0 : 1;
      final bPriority = b.lugar!.planTipo == PlanTipo.pro ? 0 : 1;
      return aPriority.compareTo(bPriority);
    }
    return 0;
  });

  return results;
});
