import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ────────────────────────────────────────────────────────────────────

enum AuthMode { login, register }

class AuthFormState {
  final AuthMode mode;
  final bool isLoading;
  final bool obscurePassword;
  final bool acceptTerms;
  final Set<String> selectedInterests;

  const AuthFormState({
    this.mode = AuthMode.login,
    this.isLoading = false,
    this.obscurePassword = true,
    this.acceptTerms = false,
    this.selectedInterests = const {},
  });

  AuthFormState copyWith({
    AuthMode? mode,
    bool? isLoading,
    bool? obscurePassword,
    bool? acceptTerms,
    Set<String>? selectedInterests,
  }) {
    return AuthFormState(
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

// ── Result type ──────────────────────────────────────────────────────────────

enum AuthResultType { success, error, info }

class AuthResult {
  final AuthResultType type;
  final String message;
  final bool shouldSwitchToLogin;

  const AuthResult({
    required this.type,
    required this.message,
    this.shouldSwitchToLogin = false,
  });
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(const AuthFormState());

  SupabaseClient get _client => Supabase.instance.client;

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == AuthMode.login ? AuthMode.register : AuthMode.login,
      obscurePassword: true,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setAcceptTerms(bool value) {
    state = state.copyWith(acceptTerms: value);
  }

  void toggleInterest(String interest) {
    final updated = Set<String>.from(state.selectedInterests);
    if (updated.contains(interest)) {
      updated.remove(interest);
    } else {
      updated.add(interest);
    }
    state = state.copyWith(selectedInterests: updated);
  }

  // ── Auth actions ─────────────────────────────────────────────────────────

  Future<AuthResult?> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'Completa todos los campos',
      );
    }
    if (!_isValidEmail(trimmedEmail)) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'Ingresa un correo válido',
      );
    }

    state = state.copyWith(isLoading: true);
    try {
      await _client.auth
          .signInWithPassword(email: trimmedEmail, password: password);
      return null; // GoRouter redirect handles navigation
    } on AuthException catch (e) {
      return AuthResult(
        type: AuthResultType.error,
        message: _translateError(e.message),
      );
    } catch (_) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'Error inesperado. Intenta de nuevo.',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<AuthResult> resetPassword({required String email}) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || !_isValidEmail(trimmedEmail)) {
      return const AuthResult(
        type: AuthResultType.info,
        message: 'Escribe tu correo arriba y luego toca aquí.',
      );
    }

    state = state.copyWith(isLoading: true);
    try {
      await _client.auth.resetPasswordForEmail(trimmedEmail);
      return const AuthResult(
        type: AuthResultType.success,
        message: 'Revisa tu correo para restablecer tu contraseña.',
      );
    } catch (_) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'No pudimos enviar el correo. Intenta de nuevo.',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<AuthResult?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!state.acceptTerms) return null;

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'Completa todos los campos',
      );
    }
    if (!_isValidEmail(trimmedEmail)) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'Ingresa un correo válido',
      );
    }
    if (password.length < 6) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'La contraseña debe tener al menos 6 caracteres',
      );
    }

    state = state.copyWith(isLoading: true);
    try {
      final response = await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {
          'nombre': trimmedName,
          'intereses': state.selectedInterests.toList(),
        },
      );

      if (response.session != null) {
        return null; // Auto-confirmed → GoRouter handles navigation
      }
      state = state.copyWith(mode: AuthMode.login);
      return const AuthResult(
        type: AuthResultType.success,
        message: '¡Cuenta creada! Revisa tu correo para confirmar.',
        shouldSwitchToLogin: true,
      );
    } on AuthException catch (e) {
      return AuthResult(
        type: AuthResultType.error,
        message: _translateError(e.message),
      );
    } catch (_) {
      return const AuthResult(
        type: AuthResultType.error,
        message: 'Error inesperado. Intenta de nuevo.',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool _isValidEmail(String email) => _emailRegex.hasMatch(email);

  String _translateError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    if (message.contains('already registered')) {
      return 'Este correo ya está registrado';
    }
    if (message.contains('valid email')) {
      return 'Ingresa un correo válido';
    }
    if (message.contains('least 6 characters')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return message;
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final authFormProvider =
    StateNotifierProvider.autoDispose<AuthFormNotifier, AuthFormState>(
  (ref) => AuthFormNotifier(),
);
