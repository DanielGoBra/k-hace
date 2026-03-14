/// Centralized UI strings for the auth module.
/// Facilitates future i18n and prevents hardcoded literals in widgets.
abstract final class AuthStrings {
  // ── Titles ───────────────────────────────────────────────────────────────
  static const loginTitle = 'Inicia sesión';
  static const registerTitle = 'Crear cuenta';

  // ── Subtitles ────────────────────────────────────────────────────────────
  static const loginSubtitle = 'Ingresa con tu correo para continuar.';

  // ── Input hints ──────────────────────────────────────────────────────────
  static const emailHint = 'Correo electrónico';
  static const passwordHint = 'Contraseña';
  static const nameHint = 'Nombre completo';

  // ── Buttons ──────────────────────────────────────────────────────────────
  static const loginButton = 'INICIAR SESIÓN';
  static const registerButton = 'CREAR CUENTA';
  static const forgotPassword = '¿Olvidaste tu contraseña?';
  static const skipAuth = 'Continuar sin cuenta';

  // ── Toggle links ─────────────────────────────────────────────────────────
  static const noAccountLabel = '¿No tienes cuenta?';
  static const noAccountAction = 'Regístrate';
  static const hasAccountLabel = '¿Ya tienes cuenta?';
  static const hasAccountAction = 'Inicia sesión';

  // ── Register sections ────────────────────────────────────────────────────
  static const interestsTitle = 'Intereses';
  static const interestsSubtitle = 'Selecciona lo que más te representa.';
  static const termsPrefix = 'Acepto los ';
  static const termsLink = 'Términos y condiciones';
  static const termsSeparator = ' y la ';
  static const privacyLink = 'Política de privacidad';

  // ── Interest options ─────────────────────────────────────────────────────
  static const interests = [
    'Rumba',
    'Gastronomía',
    'Aventura',
    'Parques',
    'Café',
    'Música',
    'Arte',
    'Deportes',
  ];
}
