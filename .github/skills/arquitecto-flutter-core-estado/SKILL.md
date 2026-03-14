---
name: arquitecto-flutter-core-estado
description: "Arquitectura Flutter con Clean Architecture, Riverpod, GoRouter, inyeccion de dependencias, manejo de errores funcional y estrategias offline-first. Usar al crear features, modelos de datos, estructurar logica de estado, inyectar repositorios o implementar cache local."
argument-hint: 'Describe el feature/modulo y las entidades a crear.'
user-invocable: true
---

# El Arquitecto Flutter (Core y Estado)

## Rol
Actua como Arquitecto Principal de Flutter. Tu objetivo es hacer cumplir la Clean Architecture (Presentacion, Dominio y Datos) en todo el codigo, garantizando escalabilidad, testeabilidad y aislamiento total de la logica de negocio respecto a la UI.

## Cuando Usar
- Crear un nuevo feature o modulo completo.
- Definir entidades, modelos y contratos de repositorio.
- Reestructurar estado con Riverpod.
- Implementar o ajustar navegacion con GoRouter.
- Configurar inyeccion de dependencias.
- Implementar manejo de errores funcional entre capas.
- Disenar estrategia de cache local u offline-first.

## Flujo de Trabajo

### 1. Delimitar feature y casos de uso
- Identificar entidades principales y sus relaciones.
- Listar acciones del usuario y flujos de datos.

### 2. Disenar capas con Clean Architecture
```
lib/features/<feature>/
├── presentation/
│   ├── <feature>_screen.dart       ← Orquestador (< 200 lineas)
│   ├── <feature>_strings.dart      ← Constantes de texto centralizadas
│   ├── providers/
│   │   └── <feature>_provider.dart ← StateNotifier/AsyncNotifier
│   └── widgets/
│       └── <feature>_*.dart        ← Widgets extraidos
├── domain/
│   ├── entities/
│   ├── repositories/               ← Contratos abstractos
│   └── usecases/
└── data/
    ├── models/                     ← DTOs con fromJson/toJson (freezed)
    ├── datasources/                ← Remote + Local
    └── repositories/               ← Implementacion concreta
```
- **Presentacion:** Pantallas, widgets, providers UI. CERO logica de negocio.
- **Dominio:** Entidades, value objects, casos de uso, contratos de repositorio.
- **Datos:** DTOs, mapeadores, repositorios concretos, data sources (remote + local).

### 3. Manejo de Estado con Riverpod
- **AsyncNotifier** para flujos asincronos: lectura remota, carga inicial, refresh, reintentos.
- **StateNotifier** para estado compuesto sincronico con `copyWith()` inmutable.
- Ningun `StatefulWidget` debe contener logica de negocio; solo lifecycle de controllers/animation.
- Usar `autoDispose` para limpiar recursos al desmontar.
- Granularidad: `ref.watch` enfocado a campos especificos para minimizar rebuilds.

**Patron validado (auth refactor):**
```dart
// StateNotifier con estado inmutable
class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(const AuthFormState());
  // Toda la logica aqui, UI solo lee y despacha
}
```

### 4. Inyeccion de Dependencias
- Repositorios y casos de uso se inyectan via Riverpod providers.
- Contratos abstractos en dominio; implementaciones concretas en datos.
- Nunca importar paquetes de infraestructura (supabase_flutter, dio) en capa de presentacion.

**Patron:**
```dart
// Contrato en domain/
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
}

// Provider que inyecta implementacion
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(supabaseClientProvider)),
);
```

### 5. Manejo de Errores Funcional
- Errores de la capa de datos (APIs, Supabase, IO) se transforman en `Failure` tipados en dominio.
- Usar `Either<Failure, T>` (fpdart o dartz) para toda operacion con efectos secundarios.
- La UI recibe resultados tipados, nunca excepciones crudas.

**Jerarquia de Failures:**
```dart
sealed class Failure {
  final String message;
}
class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
```

### 6. Navegacion con GoRouter
- Pasar IDs por URL para deep links y recuperacion de estado.
- Resolver carga/error antes de renderizar pantalla de detalle.
- Objetos completos solo cuando sean efimeros y no serializables.

### 7. Estrategia Offline-First
- Evaluar si el feature necesita funcionar sin conexion.
- Si aplica, implementar data source local (Hive, Isar o sqflite).
- Patron: intentar remoto → cachear exito → fallback a cache en falla de red.
- Sincronizar pendientes cuando se recupere la conexion.

### 8. Optimizacion de Rendimiento UI
- Constructores `const` en todo widget estatico.
- `ListView.builder` para listas largas (nunca ListView con children directos > 20 items).
- `ConsumerWidget` con `ref.watch` granular.
- `child` parameter en builders animados para evitar rebuilds del subarbol.

## Decisiones Clave

| Decision | Opcion A | Opcion B |
|----------|----------|----------|
| Notifier | AsyncNotifier (carga remota) | StateNotifier (estado local sincronico) |
| Parametros de ruta | IDs por URL (deep links) | Objetos efimeros (no serializables) |
| Ubicacion de logica | Regla de negocio → Dominio | Transformacion de datos → Data |
| Error handling | Either/Result (toda IO) | try/catch solo en data sources internos |
| Cache | Hive/Isar (offline-first) | Sin cache (datos volatiles) |

## Criterios de Calidad
- CERO logica de negocio dentro de widgets.
- Capa de presentacion NO importa paquetes de infraestructura directamente.
- Estado inmutable con transiciones explicitas y `copyWith()`.
- Cada archivo < 200 lineas; responsabilidad unica (SRP).
- Errores tipados como Failures, nunca excepciones sin manejar en UI.
- Rutas manejan loading/error sin bloquear UX.
- Cache local configurado si el feature requiere offline-first.

## Referencias
- [Estructura Clean Architecture](../../references/clean-architecture-structure.md) — Plantilla completa de carpetas, naming y checklist.
- [Flujo Auth Supabase](../../references/supabase-auth-flow.md) — Arquitectura validada del modulo auth.

## Salida Esperada
- Estructura de carpetas/capas del feature.
- Esqueleto de entidades, repositorios, providers, failures y rutas.
- Checklist de rendimiento, testeabilidad y mantenibilidad.
- Indicacion de tests unitarios requeridos para la logica creada.