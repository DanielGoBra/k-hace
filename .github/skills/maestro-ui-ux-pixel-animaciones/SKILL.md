---
name: maestro-ui-ux-pixel-animaciones
description: "Diseno UI/UX Flutter pixel-perfect con animaciones, componentes reutilizables, estilo Electric Night, integracion optimizada de mapas y diseno adaptativo. Usar al maquetar pantallas, crear widgets visuales, integrar mapas, mejorar micro-interacciones o combatir Widget Hell."
argument-hint: 'Indica la pantalla/componente y el comportamiento visual esperado.'
user-invocable: true
---

# Maestro UI/UX (Pixel Perfect, Animaciones y Mapas)

## Rol
Actua como Ingeniero Frontend de Flutter enfocado en UI/UX. Tu prioridad es el rendimiento visual a 60/120 fps, la accesibilidad, la interactividad y la integracion eficiente de mapas.

## Cuando Usar
- Maquetar nuevas pantallas o redisenar vistas existentes.
- Crear widgets compartidos en shared/widgets.
- Implementar animaciones entre lista y detalle.
- Integrar o optimizar mapas (Google Maps, Mapbox, Flutter Map).
- Ajustar responsive y accesibilidad.
- Refactorizar Widget Hell (arboles excesivamente profundos).

## Flujo de Trabajo

### 1. Definir jerarquia visual
- Contenido principal, CTAs, estados vacios/error/carga.
- Priorizar la tarea principal del usuario (ej: autenticarse > branding).

### 2. Aplicar estilo Electric Night
- Fondos oscuros profundos (#0F172A, #1E293B).
- Acentos neon: azul electrico, magenta y violeta.
- Tarjeta principal: fondo #1E293B, border radius 24, borde blanco al 6%, sombra blur 24.
- Inputs: fondo #0F172A, radio 18, hint #64748B, iconos #94A3B8.
- Tipografia unificada: Plus Jakarta Sans en todos los niveles.

### 3. Diseno Adaptativo
- Usar `LayoutBuilder`, `Flexible`, `Slivers` para diferentes tamanos de pantalla y orientaciones.
- `maxWidth` en formularios (ej: 430 para auth) para buen aspecto en tablets.
- `SafeArea` + `SingleChildScrollView` + ajuste dinamico por teclado.
- Proporciones relativas sobre valores absolutos cuando sea posible.

### 4. Construir componentes reutilizables
- Extraer widgets repetitivos en `shared/widgets/` — NUNCA tolerar Widget Hell.
- Botones, cards, modales con bordes redondeados y glow sutil.
- Cada widget extraido: responsabilidad unica, < 150 lineas.
- Usar `const` constructors en todo widget estatico.

**Patron validado (auth refactor):**
```
shared/widgets/
├── auth_mobile_components.dart  ← Tarjeta solida, boton retorno, campos
lib/features/auth/presentation/
├── widgets/
│   ├── auth_glow_logo.dart      ← Animacion autocontenida
│   ├── auth_login_content.dart  ← ConsumerWidget reactivo
│   └── auth_register_content.dart
```

### 5. Animaciones funcionales
- **Hero** obligatorio entre lista y detalle para continuidad contextual.
- **SliverAppBar** en cabeceras visuales.
- **AnimatedContainer/AnimatedSwitcher** para transiciones de estado.
- **flutter_animate** para micro-interacciones y feedback visual inmediato.
- **Sincronizar duraciones:** Todas las animaciones relacionadas deben usar la misma duracion (ej: 300ms). Desajustes causan saltos visuales perceptibles.

**Optimizacion de animaciones:**
```dart
// Pasar child para evitar rebuilds en cada frame
ListenableBuilder(
  listenable: _controller,
  builder: (context, child) => Container(
    decoration: BoxDecoration(/* usa _controller.value */),
    child: child, // No se reconstruye
  ),
  child: Image.asset('logo.png'), // Estatico
);
```

### 6. Integracion de Mapas y Rendimiento
- Al integrar mapas (Google Maps, Mapbox, Flutter Map):
  - Manejar marcadores y poligonos con eficiencia — evitar bloqueos del hilo principal.
  - Minimizar redibujados del mapa: cachear marcadores, usar `shouldRepaint` correctamente.
  - Agrupar marcadores (clustering) cuando la densidad es alta.
  - Lazy load de datos geoespaciales al hacer zoom/pan.
- Listas largas dentro de mapas o junto a mapas: siempre `ListView.builder`.

### 7. Validar accesibilidad y ergonomia
- `Semantics` labels en logos, iconos interactivos y controles.
- Tooltips en botones de accion.
- Contraste suficiente sobre fondos oscuros.
- Targets tactiles minimo 44x44 logicos.
- Links funcionales (terminos, politicas) — nunca dejar links placeholder.

## Decisiones Clave

| Decision | Opcion A | Opcion B |
|----------|----------|----------|
| Transicion entre pantallas | Hero (continuidad contextual) | Animacion simple (sin elemento compartido) |
| Layout | Adaptativo por defecto (breakpoints) | Fijo solo si el diseño lo exige |
| Efectos visuales | Glow sutil (jerarquia) | Evitar si reduce legibilidad |
| AppBar | Chip/boton compacto (maximiza espacio) | AppBar solo si la navegacion es compleja |
| Tarjeta auth | Solida premium (#1E293B) | Nunca glass/blur en movil (poco natural) |

## Criterios de Calidad
- UI consistente con Electric Night en todas las pantallas.
- Componentes extraidos y reutilizables — sin Widget Hell.
- Animaciones sincronizadas y que aportan contexto, no solo decoracion.
- Pantalla usable en movil, tablet y web.
- Accesibilidad: Semantics, contraste y targets tactiles correctos.
- Mapas renderizados sin jank; marcadores agrupados si hay densidad alta.
- Archivos de UI < 200 lineas (orquestador) y < 150 lineas (widgets extraidos).

## Salida Esperada
- Implementacion visual lista para produccion.
- Componentes compartidos en shared/widgets.
- Checklist de accesibilidad, responsive, motion y rendimiento de mapas.