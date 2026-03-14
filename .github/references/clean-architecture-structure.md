# Estructura Estándar para Nuevas Features (Flutter)

Cada nueva funcionalidad debe respetar esta jerarquía. No se permiten desviaciones sin justificación explícita.

## Estructura de Carpetas

```
lib/features/[nombre_feature]/
├── data/
│   ├── datasources/
│   │   ├── [feature]_remote_data_source.dart   ← Supabase, APIs REST, AWS
│   │   └── [feature]_local_data_source.dart    ← Hive, Isar, sqflite (si offline-first)
│   ├── models/
│   │   └── [entity]_model.dart                 ← DTO con fromJson/toJson (freezed o json_serializable)
│   └── repositories/
│       └── [feature]_repository_impl.dart      ← Implementación concreta del contrato
├── domain/
│   ├── entities/
│   │   └── [entity].dart                       ← Objetos de negocio puros (sin dependencia de framework)
│   ├── repositories/
│   │   └── [feature]_repository.dart           ← Contrato abstracto (interface)
│   └── usecases/
│       └── [accion]_[entity].dart              ← Lógica de negocio inyectable (1 caso de uso = 1 archivo)
└── presentation/
    ├── [feature]_screen.dart                   ← Orquestador (< 200 líneas)
    ├── [feature]_strings.dart                  ← Constantes de texto centralizadas
    ├── providers/
    │   └── [feature]_provider.dart             ← StateNotifier o AsyncNotifier con Riverpod
    └── widgets/
        └── [feature]_[componente].dart         ← Widgets extraídos (< 150 líneas c/u)
```

## Reglas

### Dependencias entre capas
```
Presentación → Dominio ← Datos
```
- **Presentación** depende SOLO de Dominio (entities, repository contracts, usecases).
- **Datos** depende SOLO de Dominio (implementa los contratos).
- **Dominio** NO depende de nada externo. Es Dart puro.

### Naming conventions
| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Entity | `snake_case.dart` | `evento.dart` |
| Model (DTO) | `[entity]_model.dart` | `evento_model.dart` |
| Repository (contrato) | `[feature]_repository.dart` | `events_repository.dart` |
| Repository (impl) | `[feature]_repository_impl.dart` | `events_repository_impl.dart` |
| Use case | `[verbo]_[entity].dart` | `get_nearby_events.dart` |
| Provider | `[feature]_provider.dart` | `events_provider.dart` |
| Screen | `[feature]_screen.dart` | `events_screen.dart` |
| Strings | `[feature]_strings.dart` | `events_strings.dart` |
| Widget extraído | `[feature]_[nombre].dart` | `events_card.dart` |

### Tests (espejo de la estructura)
```
test/features/[nombre_feature]/
├── data/
│   └── repositories/
│       └── [feature]_repository_impl_test.dart
├── domain/
│   └── usecases/
│       └── [accion]_[entity]_test.dart
└── presentation/
    ├── providers/
    │   └── [feature]_provider_test.dart
    └── widgets/
        └── [feature]_[componente]_test.dart
```

## Ejemplo Real: Módulo Auth (Post-refactor)

```
lib/features/auth/
├── presentation/
│   ├── auth_screen.dart            ← 155 líneas (orquestador)
│   ├── auth_strings.dart           ← 20 constantes centralizadas
│   ├── providers/
│   │   ├── auth_form_provider.dart ← StateNotifier<AuthFormState>
│   │   └── auth_providers.dart     ← AuthNotifier para GoRouter refresh
│   └── widgets/
│       ├── auth_glow_logo.dart     ← AnimationController encapsulado
│       ├── auth_login_content.dart ← ConsumerWidget reactivo
│       └── auth_register_content.dart
```

**Nota:** Auth aún no tiene capas domain/ y data/ separadas (deuda técnica documentada). El patrón completo aplica para features nuevos.

## Checklist para Nuevas Features

- [ ] Carpeta `domain/entities/` con objetos de negocio puros
- [ ] Contrato abstracto en `domain/repositories/`
- [ ] Casos de uso en `domain/usecases/` (1 por archivo)
- [ ] DTO con serialización automática en `data/models/`
- [ ] Data source remoto en `data/datasources/`
- [ ] Data source local si el feature requiere offline-first
- [ ] Implementación del repositorio en `data/repositories/`
- [ ] Provider Riverpod en `presentation/providers/`
- [ ] Screen orquestador < 200 líneas
- [ ] Strings centralizados (no hardcodeados)
- [ ] Widgets extraídos < 150 líneas
- [ ] Tests espejo en `test/features/[feature]/`
