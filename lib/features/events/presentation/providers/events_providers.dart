import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/evento.dart';

final selectedEventCategoryProvider = StateProvider<String>((ref) => 'Todos');

final selectedEventDateProvider = StateProvider<DateTime?>((ref) => null);

final eventosProvider = FutureProvider<List<Evento>>((ref) async {
  final repo = ref.read(eventoRepositoryProvider);
  final result = await repo.getEventos();
  return result.valueOrNull ?? [];
});

final filteredEventosProvider = Provider<List<Evento>>((ref) {
  final eventos = ref.watch(eventosProvider).valueOrNull ?? [];
  final category = ref.watch(selectedEventCategoryProvider);
  final selectedDate = ref.watch(selectedEventDateProvider);

  var filtered = eventos.toList();

  if (category != 'Todos') {
    filtered = filtered.where((e) => e.categoria == category).toList();
  }

  if (selectedDate != null) {
    filtered = filtered.where((e) {
      return e.fechaInicio.year == selectedDate.year &&
          e.fechaInicio.month == selectedDate.month &&
          e.fechaInicio.day == selectedDate.day;
    }).toList();
  }

  filtered.sort((a, b) {
    if (a.esDestacado && !b.esDestacado) return -1;
    if (!a.esDestacado && b.esDestacado) return 1;
    return a.fechaInicio.compareTo(b.fechaInicio);
  });

  return filtered;
});

final savedEventsProvider =
    StateNotifierProvider<SavedEventsNotifier, Set<String>>((ref) {
  return SavedEventsNotifier();
});

class SavedEventsNotifier extends StateNotifier<Set<String>> {
  SavedEventsNotifier() : super(<String>{});

  void toggleEvent(String id) {
    final newState = Set<String>.from(state);
    if (newState.contains(id)) {
      newState.remove(id);
    } else {
      newState.add(id);
    }
    state = newState;
  }

  bool isSaved(String id) => state.contains(id);
}
