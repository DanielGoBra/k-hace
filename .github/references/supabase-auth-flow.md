# Flujo de Autenticación con Supabase — Referencia Técnica

## Arquitectura del Módulo Auth

```
User → AuthScreen (orquestador)
         │
         ├── AuthLoginContent (ConsumerWidget)
         │     └── ref.read(authFormProvider.notifier).login(email, pass)
         │
         └── AuthRegisterContent (ConsumerWidget)
               └── ref.read(authFormProvider.notifier).register(...)
                           │
                           ▼
                  AuthFormNotifier (StateNotifier)
                           │
                           ├── Validación local (email regex, longitud)
                           ├── Supabase.instance.client.auth.signInWithPassword()
                           ├── Traducción de errores → español colombiano
                           └── AuthResult tipado → UI muestra feedback
                           │
                           ▼
                  AuthNotifier (ChangeNotifier)
                           │
                           └── onAuthStateChange → GoRouter redirect
```

## Tokens y Sesión

### Flujo de login
1. Usuario ingresa email + contraseña.
2. `AuthFormNotifier.login()` valida localmente.
3. Llama `signInWithPassword()` → Supabase devuelve `Session` con `access_token` + `refresh_token`.
4. Supabase SDK almacena tokens localmente (secure storage del SDK).
5. `AuthNotifier` detecta cambio de estado → GoRouter redirige a home.

### Renovación automática
- Supabase Flutter SDK renueva automáticamente el `access_token` usando el `refresh_token`.
- Si el refresh falla (token expirado, revocado), `onAuthStateChange` emite `signedOut`.
- GoRouter detecta `isAuthenticated == false` → redirige a auth.

### Cierre de sesión
```dart
await Supabase.instance.client.auth.signOut();
// signOut() limpia tokens locales y invalida sesión en servidor
// onAuthStateChange emite signedOut → GoRouter redirige
```

## Traducción de Errores

El `AuthFormNotifier` traduce errores de Supabase a mensajes legibles:

| Error Supabase | Mensaje mostrado |
|----------------|------------------|
| `Invalid login credentials` | "Correo o contraseña incorrectos" |
| `User already registered` | "Este correo ya tiene cuenta" |
| `Email not confirmed` | "Revisa tu correo para confirmar la cuenta" |
| `Password should be at least 6 characters` | "La contraseña debe tener al menos 6 caracteres" |
| Timeout / Network error | "Sin conexión. Revisa tu internet" |
| Otros | "Ocurrió un error. Intenta de nuevo" |

## Validaciones

### Cliente (AuthFormNotifier)
- Email: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- Contraseña: mínimo 6 caracteres
- Campos obligatorios: email + password (login), + name (registro)
- Términos aceptados (solo registro)

### Servidor (Supabase)
- Email único por proyecto
- Contraseña hasheada con bcrypt
- RLS activo en todas las tablas

## Providers Riverpod

```dart
// Estado del formulario: modo, loading, inputs, selecciones
final authFormProvider = StateNotifierProvider.autoDispose<AuthFormNotifier, AuthFormState>(
  (ref) => AuthFormNotifier(),
);

// Estado de sesión: GoRouter escucha cambios para redirects
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>(
  (ref) => AuthNotifier(),
);
```

## Deuda técnica pendiente

| Prioridad | Item |
|-----------|------|
| Alta | Auth social (Google, Facebook, Apple) — UI lista, backend pendiente |
| Media | Links de Términos y Política de privacidad funcionales |
| Media | Tests unitarios del AuthFormNotifier |
| Baja | Migrar auth a Clean Architecture completa (domain/ + data/) |
| Baja | i18n con flutter_localizations |
