import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── State ────────────────────────────────────────────────────────────────────

class NotificationPrefs {
  final bool eventos;
  final bool promociones;
  final bool nuevosLugares;
  final bool recomendaciones;

  const NotificationPrefs({
    this.eventos = true,
    this.promociones = true,
    this.nuevosLugares = false,
    this.recomendaciones = true,
  });

  NotificationPrefs copyWith({
    bool? eventos,
    bool? promociones,
    bool? nuevosLugares,
    bool? recomendaciones,
  }) {
    return NotificationPrefs(
      eventos: eventos ?? this.eventos,
      promociones: promociones ?? this.promociones,
      nuevosLugares: nuevosLugares ?? this.nuevosLugares,
      recomendaciones: recomendaciones ?? this.recomendaciones,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs()) {
    _load();
  }

  static const _keyEventos = 'notif_eventos';
  static const _keyPromos = 'notif_promociones';
  static const _keyNuevos = 'notif_nuevos_lugares';
  static const _keyRecomendaciones = 'notif_recomendaciones';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPrefs(
      eventos: prefs.getBool(_keyEventos) ?? true,
      promociones: prefs.getBool(_keyPromos) ?? true,
      nuevosLugares: prefs.getBool(_keyNuevos) ?? false,
      recomendaciones: prefs.getBool(_keyRecomendaciones) ?? true,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_keyEventos, state.eventos),
      prefs.setBool(_keyPromos, state.promociones),
      prefs.setBool(_keyNuevos, state.nuevosLugares),
      prefs.setBool(_keyRecomendaciones, state.recomendaciones),
    ]);
  }

  void setEventos(bool value) {
    state = state.copyWith(eventos: value);
    _save();
  }

  void setPromociones(bool value) {
    state = state.copyWith(promociones: value);
    _save();
  }

  void setNuevosLugares(bool value) {
    state = state.copyWith(nuevosLugares: value);
    _save();
  }

  void setRecomendaciones(bool value) {
    state = state.copyWith(recomendaciones: value);
    _save();
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  (ref) => NotificationPrefsNotifier(),
);
