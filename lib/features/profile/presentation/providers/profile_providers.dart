import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/user_profile.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      return UserProfileNotifier();
    });

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  StreamSubscription<AuthState>? _authSub;

  UserProfileNotifier() : super(null) {
    // Set initial state from current session
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) _setFromUser(user);

    // Listen for auth changes
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        _setFromUser(data.session?.user);
      } else if (event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });
  }

  void _setFromUser(User? user) {
    if (user == null) {
      state = null;
      return;
    }
    final meta = user.userMetadata ?? {};
    state = UserProfile(
      id: user.id,
      nombre:
          meta['nombre'] as String? ??
          user.email?.split('@').first ??
          'Usuario',
      email: user.email ?? '',
      ciudad: meta['ciudad'] as String? ?? 'Medellín',
      intereses: meta['intereses'] is List
          ? List<String>.from(meta['intereses'] as List)
          : <String>[],
      fechaRegistro: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  Future<void> updateProfile({
    String? nombre,
    String? ciudad,
    List<String>? intereses,
  }) async {
    final updates = <String, dynamic>{};
    if (nombre != null) updates['nombre'] = nombre;
    if (ciudad != null) updates['ciudad'] = ciudad;
    if (intereses != null) updates['intereses'] = intereses;

    if (updates.isEmpty) return;

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(data: updates),
    );
    _setFromUser(Supabase.instance.client.auth.currentUser);
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    // state is set to null by the auth listener
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider) != null;
});
