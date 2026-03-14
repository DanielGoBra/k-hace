# 📋 Plan de Mejora — ¿K hace! v1.0

> **Fecha:** 13 de marzo de 2026  
> **Estado actual:** MVP funcional con UI pulida, datos mock, auth Supabase básica  
> **Objetivo:** Llevar el proyecto a producción con arquitectura escalable, código mantenible y datos reales

---

## 1. AUDITORÍA DEL ESTADO ACTUAL

### 1.1 Fortalezas ✅
| Área | Detalle |
|------|---------|
| UI/UX | Paleta Night Metalist coherente, GradientText, GIF background, dark/light mode |
| Widgets compartidos | 15+ widgets reutilizables bien extraídos (QshScaffoldBackground, PulseCard, etc.) |
| Navegación | GoRouter con ShellRoute para tabs, deep-link support, auth gating |
| Estado | Riverpod como contenedor, providers separados por feature |
| Tema | Centralizado con extensión semántica de BuildContext |
| Análisis estático | 0 warnings en `dart analyze` |

### 1.2 Deuda Técnica Crítica 🔴
| # | Issue | Impacto | Archivos afectados |
|---|-------|---------|-------------------|
| D1 | **Secretos hardcoded** — Supabase URL/Key y Mapbox token en código fuente | Seguridad | `app_constants.dart` |
| D2 | **Sin repositorios ni abstracciones** — Providers acceden directo a Supabase | Testabilidad, acoplamiento | `home_providers.dart`, `profile_providers.dart`, `auth_form_provider.dart` |
| D3 | **Datos mock embebidos en domain** — `mockLugares`, `mockEventos`, `mockNotifications` mezclados con modelos | Separación de capas | `lugar.dart`, `evento.dart`, `app_notification.dart` |
| D4 | **Signing config de release usa debug keys** | No se puede publicar en Play Store | `android/app/build.gradle.kts` |
| D5 | **APK de 163 MB** — sin split por ABI ni app bundle | Distribución | Build config |
| D6 | **0 tests útiles** — único test está desactualizado | Calidad, regresiones | `test/widget_test.dart` |
| D7 | **Map screen monolítico** — ~500+ líneas con permisos, layers, filtros, UI | Mantenibilidad | `map_screen.dart` |

### 1.3 Deuda Técnica Media 🟡
| # | Issue | Archivos |
|---|-------|----------|
| M1 | Listas de categorías duplicadas entre home y map | `home_screen.dart`, `map_screen.dart` |
| M2 | Formateo de fechas duplicado | `event_card.dart`, `event_detail_screen.dart` |
| M3 | Validación de auth duplicada | `auth_form_provider.dart`, `auth_mobile_components.dart` |
| M4 | Patrón fallback `isEmpty ? mock : real` repetido | Varios providers |
| M5 | Patrón image asset/network duplicado en 6+ widgets | `pulse_card.dart`, `compact_pulse_card.dart`, etc. |
| M6 | Bug: onboarding navega a `/` que no existe | `onboarding_screen.dart` |
| M7 | Features placeholder incompletos (compartir, PDF, calendario, social login, transporte) | Varios |
| M8 | No hay manejo de errores tipado (sin Either/Result/Failures) | Toda la capa de datos |

---

## 2. PLAN DE EJECUCIÓN POR FASES

### ═══════════════════════════════════════════════
### FASE 0 — Preparación GitHub & CI/CD
### ═══════════════════════════════════════════════

**Objetivo:** Proyecto listo para colaboración y CI

| # | Tarea | Prioridad | Esfuerzo |
|---|-------|-----------|----------|
| 0.1 | Crear `.gitignore` robusto (build/, .env, *.jks, debug-info/, local.properties) | 🔴 Crítica | Bajo |
| 0.2 | Externalizar secretos a `--dart-define` y `.env` (no commitear) | 🔴 Crítica | Bajo |
| 0.3 | Crear `README.md` profesional (setup, requisitos, screenshots, arquitectura) | 🟡 Alta | Medio |
| 0.4 | Crear `CONTRIBUTING.md` con convenciones (commits, branches, PR) | 🟢 Media | Bajo |
| 0.5 | Configurar GitHub Actions: `flutter analyze` + `flutter test` en PR | 🟡 Alta | Medio |
| 0.6 | Agregar `very_good_analysis` o reglas de lint estrictas | 🟡 Alta | Bajo |
| 0.7 | Crear estructura de branches: `main`, `develop`, `feature/*` | 🟢 Media | Bajo |
| 0.8 | Limpiar pubspec.yaml (quitar comentarios template, agregar description real) | 🟢 Media | Bajo |

### ═══════════════════════════════════════════════
### FASE 1 — Arquitectura Clean + DI
### ═══════════════════════════════════════════════

**Objetivo:** Separación estricta de capas para cada feature

#### 1A. Estructura target por feature:
```
lib/features/<feature>/
  ├── domain/
  │   ├── entities/          # Modelos puros (sin dependencias externas)
  │   ├── repositories/      # Contratos abstractos
  │   └── usecases/          # Lógica de negocio (opcional si es simple)
  ├── data/
  │   ├── datasources/       # Implementaciones remotas (Supabase) y locales
  │   ├── repositories/      # Implementación concreta del contrato
  │   ├── models/            # DTOs con fromJson/toJson (freezed o json_serializable)
  │   └── mappers/           # DTO → Entity
  └── presentation/
      ├── screens/
      ├── widgets/
      ├── providers/         # Riverpod providers que usan usecases/repos
      └── state/             # State classes (AsyncValue patterns)
```

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1.1 | Agregar `freezed`, `json_serializable`, `build_runner` al proyecto | 🔴 |
| 1.2 | Crear sistema de DI con Riverpod: `repositoryProviders.dart` por feature | 🔴 |
| 1.3 | Extraer mock data a `data/datasources/local/` como datasource local | 🔴 |
| 1.4 | Crear contratos de repositorio abstractos en `domain/repositories/` | 🔴 |
| 1.5 | Migrar `Lugar` y `Evento` a modelos freezed con serialización | 🟡 |
| 1.6 | Implementar `Result<T>` o `Either<Failure, T>` para manejo de errores | 🟡 |
| 1.7 | Crear `Failure` classes tipados (ServerFailure, CacheFailure, AuthFailure) | 🟡 |

#### 1B. Ejemplo concreto — Feature "Lugares":
```dart
// domain/repositories/lugar_repository.dart
abstract class LugarRepository {
  Future<Result<List<Lugar>>> getLugares();
  Future<Result<Lugar>> getLugarById(String id);
  Future<Result<List<Lugar>>> searchLugares(String query);
}

// data/repositories/lugar_repository_impl.dart
class LugarRepositoryImpl implements LugarRepository {
  final LugarRemoteDataSource _remote;
  final LugarLocalDataSource _local;
  // ...failover logic, caching
}

// presentation/providers/lugar_providers.dart
final lugarRepositoryProvider = Provider<LugarRepository>((ref) {
  return LugarRepositoryImpl(
    remote: ref.read(supabaseDataSourceProvider),
    local: ref.read(localDataSourceProvider),
  );
});
```

### ═══════════════════════════════════════════════
### FASE 2 — Conexión Supabase Real
### ═══════════════════════════════════════════════

**Objetivo:** Datos reales desde Supabase con tablas diseñadas

#### 2A. Diseño de base de datos Supabase:

```sql
-- Tablas principales
lugares (
  id UUID PK DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  imagen_url TEXT,
  categoria TEXT NOT NULL,           -- 'restaurante', 'parque', 'museo', etc.
  rating DECIMAL(2,1) DEFAULT 0,
  latitud DOUBLE PRECISION NOT NULL,
  longitud DOUBLE PRECISION NOT NULL,
  direccion TEXT,
  telefono TEXT,
  horario JSONB,                     -- {"lunes": "8:00-18:00", ...}
  precio_rango TEXT,                 -- '$', '$$', '$$$'
  tags TEXT[],
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
)

eventos (
  id UUID PK DEFAULT uuid_generate_v4(),
  titulo TEXT NOT NULL,
  descripcion TEXT,
  imagen_url TEXT,
  lugar_id UUID REFERENCES lugares(id),
  fecha_inicio TIMESTAMPTZ NOT NULL,
  fecha_fin TIMESTAMPTZ,
  precio DECIMAL(10,2) DEFAULT 0,
  categoria TEXT NOT NULL,
  capacidad INTEGER,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
)

perfiles (
  id UUID PK REFERENCES auth.users(id),
  nombre TEXT,
  avatar_url TEXT,
  ciudad TEXT DEFAULT 'Medellín',
  intereses TEXT[],
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
)

favoritos (
  id UUID PK DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  lugar_id UUID REFERENCES lugares(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, lugar_id)
)

resenas (
  id UUID PK DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  lugar_id UUID REFERENCES lugares(id),
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  comentario TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
)

notificaciones (
  id UUID PK DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  tipo TEXT NOT NULL,                -- 'evento', 'promo', 'sistema'
  leida BOOLEAN DEFAULT false,
  data JSONB,                        -- metadata flexible
  created_at TIMESTAMPTZ DEFAULT now()
)
```

| # | Tarea | Prioridad |
|---|-------|-----------|
| 2.1 | Crear tablas en Supabase con migrations SQL | 🔴 |
| 2.2 | Configurar Row Level Security (RLS) para cada tabla | 🔴 |
| 2.3 | Seed data: migrar los 8 mockLugares + 8 mockEventos a la BD | 🟡 |
| 2.4 | Crear Supabase Edge Functions para lógica server-side si la necesitas | 🟢 |
| 2.5 | Implementar `LugarRemoteDataSource` con queries Supabase | 🔴 |
| 2.6 | Implementar `EventoRemoteDataSource` | 🔴 |
| 2.7 | Implementar `FavoritosRepository` (actualmente es local con SharedPrefs) | 🟡 |
| 2.8 | Implementar `PerfilRepository` (actualmente lee metadata de auth) | 🟡 |
| 2.9 | Implementar `NotificacionesRepository` | 🟡 |
| 2.10 | Configurar Supabase Realtime para notificaciones push | 🟢 |
| 2.11 | Implementar sistema de Storage para imágenes de perfil/lugares | 🟢 |

### ═══════════════════════════════════════════════
### FASE 3 — Lógica de Negocio
### ═══════════════════════════════════════════════

**Objetivo:** Features funcionales con datos reales y lógica robusta

| # | Tarea | Prioridad |
|---|-------|-----------|
| 3.1 | **Búsqueda real** — Full-text search en Supabase (lugares + eventos) | 🔴 |
| 3.2 | **Favoritos sincronizados** — Persistir en BD, sync offline/online | 🔴 |
| 3.3 | **Filtros de mapa** — Queries por categoría, radio, rating | 🟡 |
| 3.4 | **Sistema de reseñas** — CRUD con rating promedio calculado | 🟡 |
| 3.5 | **Notificaciones reales** — Push notifications con Supabase Realtime o FCM | 🟡 |
| 3.6 | **Perfil editable** — Upload avatar, editar nombre/ciudad/intereses | 🟡 |
| 3.7 | **Eventos por fecha** — Filtros por "hoy", "esta semana", "este mes" | 🟢 |
| 3.8 | **Geolocalización activa** — Ordenar lugares por cercanía, "cerca de ti" | 🟢 |
| 3.9 | **Deep links funcionales** — Compartir lugar/evento con URL que abra la app | 🟢 |
| 3.10 | **Analytics básico** — Tracking de vistas, búsquedas, favoritos | 🟢 |

### ═══════════════════════════════════════════════
### FASE 4 — Refactorización & Optimización
### ═══════════════════════════════════════════════

**Objetivo:** Código limpio, performante y libre de duplicación

| # | Tarea | Prioridad |
|---|-------|-----------|
| 4.1 | **Descomponer `map_screen.dart`** en: MapView, MapFilters, MapMarkers, MapBottomSheet | 🔴 |
| 4.2 | **Extraer categorías** a constante única compartida (eliminar duplicación home/map) | 🔴 |
| 4.3 | **Crear `QshImage` widget** unificado que maneja asset/network/placeholder/error | 🟡 |
| 4.4 | **Crear `DateFormatter` utility** (eliminar formateo de fechas duplicado) | 🟡 |
| 4.5 | **Extraer validación de auth** a utility compartido | 🟡 |
| 4.6 | **Fix bug onboarding** — Ruta `/` no existe, cambiar a `/explore` | 🔴 |
| 4.7 | **Migrar a AsyncNotifier** de Riverpod 2.x para consistencia | 🟢 |
| 4.8 | **Implementar paginación** en listas de lugares y eventos | 🟡 |
| 4.9 | **Lazy loading de imágenes** con `cached_network_image` | 🟡 |
| 4.10 | **Reducir tamaño APK** — App Bundle + split por ABI (~40MB vs 163MB) | 🔴 |
| 4.11 | **Eliminar/completar features placeholder** (compartir, PDF, calendario, transporte) | 🟢 |

### ═══════════════════════════════════════════════
### FASE 5 — Testing & Calidad
### ═══════════════════════════════════════════════

**Objetivo:** Cobertura >70% en lógica, >50% en widgets

| # | Tarea | Prioridad |
|---|-------|-----------|
| 5.1 | Configurar testing infrastructure (mocktail, fake Supabase client) | 🔴 |
| 5.2 | Unit tests: Repositories (todas las features) | 🔴 |
| 5.3 | Unit tests: Auth flow (login, register, logout, token refresh) | 🔴 |
| 5.4 | Unit tests: Providers de estado (favoritos, búsqueda, perfil) | 🟡 |
| 5.5 | Unit tests: `ciiu_category_mapper.dart` | 🟢 |
| 5.6 | Widget tests: Auth screen flow (login ↔ registro) | 🟡 |
| 5.7 | Widget tests: Home screen con datos mock | 🟡 |
| 5.8 | Widget tests: Navegación entre tabs | 🟢 |
| 5.9 | Integration tests: Flujo completo auth → home → detalle → favorito | 🟢 |
| 5.10 | Golden tests: Componentes visuales clave (PulseCard, GradientText) | 🟢 |

### ═══════════════════════════════════════════════
### FASE 6 — Release & Distribución
### ═══════════════════════════════════════════════

**Objetivo:** App lista para Google Play y distribución con socios

| # | Tarea | Prioridad |
|---|-------|-----------|
| 6.1 | Configurar **release signing** real (keystore .jks) | 🔴 |
| 6.2 | Generar **App Bundle** (.aab) optimizado para Play Store | 🔴 |
| 6.3 | Configurar **flavors** (dev, staging, prod) con diferentes Supabase URLs | 🟡 |
| 6.4 | **Splash screen** nativo (flutter_native_splash) | 🟡 |
| 6.5 | **App icon** final optimizado para todas las densidades | 🟡 |
| 6.6 | Metadata Play Store (screenshots, descripción, categoría) | 🟢 |
| 6.7 | **ProGuard rules** optimizadas para librerías nativas | 🟢 |
| 6.8 | Configurar **Firebase Crashlytics** con debug symbols del obfuscate | 🟢 |

---

## 3. ORDEN DE EJECUCIÓN RECOMENDADO

```
Semana 1-2 ──► FASE 0 (GitHub + CI) + FASE 4.6 (bug fix onboarding)
    │
    ▼
Semana 3-4 ──► FASE 1 (Clean Architecture base)
    │           Reestructurar features: home, auth, events
    ▼
Semana 5-6 ──► FASE 2 (Supabase real)
    │           Tablas + RLS + DataSources + Seed
    ▼
Semana 7-8 ──► FASE 3 (Lógica de negocio)
    │           Búsqueda, favoritos sync, filtros
    ▼
Semana 9   ──► FASE 4 (Refactorización)
    │           Map decomposition, QshImage, utilities
    ▼
Semana 10  ──► FASE 5 (Testing)
    │           Repos + Auth + Providers + Widget tests
    ▼
Semana 11  ──► FASE 6 (Release)
                Signing, App Bundle, flavors, metadata
```

---

## 4. DEPENDENCIAS A AGREGAR

```yaml
# pubspec.yaml - nuevas dependencias planeadas
dependencies:
  freezed_annotation: ^3.0.0      # Modelos inmutables
  json_annotation: ^4.9.0          # Serialización
  cached_network_image: ^3.4.1     # Cache de imágenes
  intl: ^0.20.2                    # Formateo de fechas/moneda
  connectivity_plus: ^6.1.4        # Detección offline
  flutter_secure_storage: ^9.2.4   # Almacenamiento seguro de tokens
  envied: ^1.1.0                   # Variables de entorno type-safe

dev_dependencies:
  freezed: ^3.0.0                  # Code generation
  json_serializable: ^6.9.5        # JSON codegen
  build_runner: ^2.4.15            # Builder
  mocktail: ^1.0.4                 # Mocking para tests
  very_good_analysis: ^7.0.0       # Lint rules estrictas
  envied_generator: ^1.1.0         # Env var codegen
```

---

## 5. MÉTRICAS DE ÉXITO

| Métrica | Actual | Target |
|---------|--------|--------|
| Warnings en `dart analyze` | 0 | 0 |
| Test coverage | ~0% | >70% lógica, >50% total |
| Tamaño APK | 163 MB | <50 MB (App Bundle) |
| Secretos en código | 2 (Supabase, Mapbox) | 0 |
| Datos mock en producción | 3 archivos | 0 (todos en BD) |
| Features con Clean Architecture | 0 | Todos (7 features) |
| Tiempo de primera carga | Sin medir | <3s |
| Crash rate | Sin medir | <1% |

---

## 6. ARCHIVOS QUE SE CREARÁN/MODIFICARÁN (ESTIMADO)

### Nuevos (~45 archivos):
```
lib/core/errors/failures.dart
lib/core/errors/result.dart
lib/core/utils/date_formatter.dart
lib/core/utils/image_helper.dart
lib/core/di/providers.dart
lib/shared/widgets/qsh_image.dart

lib/features/home/domain/entities/lugar.dart
lib/features/home/domain/repositories/lugar_repository.dart
lib/features/home/data/models/lugar_model.dart
lib/features/home/data/datasources/lugar_remote_datasource.dart
lib/features/home/data/datasources/lugar_local_datasource.dart
lib/features/home/data/repositories/lugar_repository_impl.dart

(patrón similar × 6 features más)

test/features/home/data/repositories/lugar_repository_test.dart
test/features/auth/presentation/providers/auth_provider_test.dart
(... ~15 test files)

.github/workflows/ci.yml
.env.example
```

### Modificados (~25 archivos):
```
lib/main.dart                         → DI setup, env vars
lib/core/constants/app_constants.dart  → Eliminar secretos
lib/core/router/app_router.dart        → Fix ruta onboarding
lib/features/map/presentation/*        → Decomposición
lib/features/home/presentation/*       → Clean architecture wiring
pubspec.yaml                           → Nuevas deps
analysis_options.yaml                  → Lint estrictos
android/app/build.gradle.kts           → Release signing
.gitignore                             → Seguridad
```

---

> **Siguiente paso inmediato:** Fase 0 — Preparar el repositorio GitHub con `.gitignore`, externalizar secretos y crear el README profesional.
