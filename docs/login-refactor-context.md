# Contexto de refactor auth

Fecha: 2026-03-12

## Objetivo
Mejorar el sistema de autenticación con enfoque mobile-first, corrigiendo dos problemas principales:
- Exceso de espacio vertical entre branding y campos.
- Contenedor tipo glass/blur poco natural en móvil.

## Archivos intervenidos
- lib/features/auth/presentation/auth_screen.dart
- lib/features/auth/presentation/login_screen.dart
- lib/features/auth/presentation/register_screen.dart
- lib/shared/widgets/auth_mobile_components.dart
- lib/core/theme/app_theme.dart
- lib/shared/widgets/qsh_chip.dart

## Cambios realizados
- Se eliminó la composición editorial de dos bloques para esta pantalla y se consolidó en una sola tarjeta centrada y compacta.
- Se retiró el uso de panel difuminado en login y se reemplazó por una tarjeta sólida premium.
- Se mantuvo el fondo animado, pero con una composición más controlada para que funcione como atmósfera y no como ruido visual.
- Se añadió una navegación de retorno compacta tipo chip en lugar de usar una AppBar completa.
- Se aseguró ergonomía móvil con SafeArea, SingleChildScrollView y ajuste dinámico por teclado.
- Se extrajeron componentes reutilizables para toda la familia auth: tarjeta sólida, botón de retorno y campos consistentes.
- Se refactorizó auth_screen para eliminar FrostedAuthPanel y convertirlo en una entrada premium, compacta y coherente con el login.
- Se refactorizó register_screen para usar la misma superficie sólida, el mismo sistema de inputs y una jerarquía más clara en intereses y términos.

## Valores de diseño aplicados
### Tarjeta principal
- Fondo: #1E293B
- Border radius: 24
- Border sutil: blanco al 6 por ciento
- Sombra: color #24000000, blur 24, offset vertical 10
- Padding interno: izquierda 24, arriba 24, derecha 24, abajo 20

### Branding y espaciado
- Logo dentro de la tarjeta con maxWidth 104
- Espacio entre logo y título: 24
- Espacio entre texto descriptivo y primer input: 28
- Espacio entre inputs: 14
- Espacio entre password y acción de recuperación: 8
- Espacio antes del CTA principal: 14

### Inputs
- Fondo de campo: #0F172A
- Radio de campo: 18
- Hint: #64748B
- Iconos: #94A3B8
- Borde enfocado: AppTheme.primary con ancho 1.2
- Content padding vertical: 18

### Contenedor general
- Padding del fondo animado: izquierda 16, arriba 10, derecha 16, abajo 18 + keyboard inset
- Ancho máximo del formulario: 430

## Valores adicionales por pantalla
### AuthScreen
- Tarjeta principal con padding: 24, 28, 24, 20
- Logo: maxWidth 132
- Headline: Plus Jakarta Sans 28, peso 700, tracking -0.9
- Módulos de valor: radio 18, icon block 40, separación vertical 12

### RegisterScreen
- Misma tarjeta base que login para continuidad visual
- Sección de intereses con spacing 10 y runSpacing 10
- Bloque de términos dentro de contenedor sólido con padding 14 y radio 16
- CTA separado 18 px del bloque de términos para evitar saturación táctil

## Decisiones UX
- Se evitó una AppBar tradicional porque en móvil consume altura útil y empuja el formulario hacia abajo.
- El login quedó centrado visualmente, pero dentro de un scroll para que el teclado no tape el botón principal.
- La tarjeta sólida mejora jerarquía y legibilidad sobre el GIF, especialmente en pantallas pequeñas.
- Se redujo el peso visual del branding para priorizar la tarea principal: autenticarse.
- AuthScreen ahora funciona como puerta de entrada clara, sin salto visual con respecto al login.
- RegisterScreen conserva densidad funcional, pero con grupos mejor separados para que el formulario siga siendo legible y usable con el pulgar.

## Validación realizada
- Verificación del archivo con diagnóstico del editor: sin errores.
- Revisión estructural del widget tras reconstrucción completa: correcta.
- Verificación de auth_screen, login_screen, register_screen y auth_mobile_components: sin errores reportados por el editor.
- El sistema auth quedó estable y listo para pasar a otras áreas.

## Estado actual
- auth_screen, login_screen y register_screen ya comparten lenguaje visual base.
- FrostedAuthPanel dejó de ser parte del flujo auth principal.
- El siguiente nivel recomendable ya no es visual básico sino pruebas de interacción real en dispositivo y microajustes de spacing si cambia el teclado o el escalado del sistema.

---

## Iteración 2 — Consolidación tipográfica + mejoras estructurales

Fecha: 2026-03-12

### Tipografía unificada: Plus Jakarta Sans
- Se reemplazó Inter (body/UI) y Sora (headlines) por una única fuente: Plus Jakarta Sans.
- Motivo: fuente geométrica, moderna y con personalidad fresca, alineada con el público objetivo de 18 a 45 años.
- Se aplicó en todo el theme global (displayLarge, headlineMedium, titleLarge, titleMedium, bodyLarge, bodyMedium, labelLarge, appBar, botones elevados y outlined).
- Se creó el helper AppTheme.headline() para títulos auth, eliminando las llamadas directas a GoogleFonts.sora que existían en auth_screen, login_screen y register_screen.
- Ya no quedan referencias a GoogleFonts.inter ni GoogleFonts.sora en el proyecto.

### Nuevas constantes centralizadas en AppTheme
- AppTheme.textTertiary (#CBD5E1): reemplaza 11 usos de Color(0xFFCBD5E1) hardcodeado.
- AppTheme.hintColor (#64748B): color de hint en inputs.
- AppTheme.border6 (blanco 6%): borde sutil reutilizado en tarjetas, inputs y contenedores.
- AppTheme.overlay4 (blanco 4%): fondo de contenedores informativos y value rows.

### Nuevo widget: AuthScaffold
- Extrae el patrón repetido Scaffold > AmbientGifBackground > SafeArea > LayoutBuilder > SingleChildScrollView > ConstrainedBox(430) que compartían las tres pantallas.
- Reduce aproximadamente 20 líneas de boilerplate por pantalla.
- Ubicado en auth_mobile_components.dart junto a los demás componentes auth.

### Nuevo mixin: AuthFeedbackMixin
- Centraliza showAuthError, showAuthSuccess y showAuthInfo (snackbars).
- Incluye translateAuthError con todas las traducciones de errores de Supabase (login + registro unificados).
- Incluye isValidEmail para validación básica client-side antes de llamar al servidor.
- Aplicado en LoginScreen y RegisterScreen, eliminando métodos duplicados _showError, _showInfo, _showSuccess y _translateAuthError.

### Nuevo widget: AuthNavigationLink
- Reemplaza los GestureDetector sobre texto plano que se usaban para "Regístrate" e "Inicia sesión".
- Usa TextButton con ripple, tap target mínimo de 48px y semántica accesible.
- Aplicado en login_screen y register_screen.

### FocusNode en todos los campos
- Se añadieron FocusNode explícitos en login_screen (email, password) y register_screen (name, email, password).
- TextInputAction.next ahora mueve el foco correctamente al siguiente campo con requestFocus, garantizando el flujo en iOS y web además de Android.

### Recuperación de contraseña funcional
- El botón "¿Olvidaste tu contraseña?" en login_screen ahora llama a Supabase.instance.client.auth.resetPasswordForEmail.
- Si el campo de email está vacío o inválido, muestra un mensaje guía en lugar de fallar silenciosamente.
- Se eliminó el placeholder "estará disponible pronto".

### Bloque OAuth placeholder eliminado
- Se removió el contenedor informativo de login_screen que decía "Acceso con Google y Apple se habilitará en una siguiente iteración".
- Motivo: ocupaba espacio visual valioso sin función y generaba expectativa sobre una feature no disponible.

### Guard defensivo en registro
- Se añadió if (!_acceptTerms) return como primera línea de _register() para evitar ejecución si se invoca el método fuera del botón (por ejemplo desde onSubmitted del teclado).

### Validación de email client-side
- Tanto login como register ahora validan formato básico de email (contiene @ y .) antes de enviar al servidor.
- Evita round-trips innecesarios a Supabase por emails claramente inválidos.

### QshChip accesible
- Se reemplazó GestureDetector por Material + InkWell en qsh_chip.dart.
- Ahora tiene feedback visual (ripple) al tocar y es compatible con lectores de pantalla.

### Validación
- flutter analyze sobre los 6 archivos modificados: 0 errores, 0 warnings.
- No quedan referencias a GoogleFonts.inter ni GoogleFonts.sora en el proyecto.
- Todos los colores hardcodeados en el flujo auth fueron reemplazados por constantes de AppTheme.
