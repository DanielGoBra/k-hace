# Guia de contribucion — ¿K hace!

## Branches

| Branch | Proposito |
|--------|----------|
| `main` | Produccion estable. Solo merges desde `develop` via PR aprobado. |
| `develop` | Integracion. Todas las features se mergean aqui primero. |
| `feature/<nombre>` | Desarrollo de nuevas funcionalidades. |
| `fix/<nombre>` | Correccion de bugs. |
| `hotfix/<nombre>` | Parches urgentes sobre `main`. |

## Flujo de trabajo

1. Crear branch desde `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/mi-feature
   ```

2. Desarrollar con commits atomicos (ver convenciones abajo).

3. Antes de hacer PR:
   ```bash
   flutter analyze        # 0 warnings
   flutter test           # Todos los tests pasan
   ```

4. Crear PR hacia `develop` con descripcion clara.

5. Al menos 1 aprobacion requerida para merge.

## Convenciones de commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<scope>): <descripcion corta>

[cuerpo opcional]
```

**Tipos permitidos:**

| Tipo | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Correccion de bug |
| `refactor` | Cambio de codigo sin alterar comportamiento |
| `style` | Formato, linting (sin cambios logicos) |
| `docs` | Documentacion |
| `test` | Tests nuevos o corregidos |
| `chore` | Mantenimiento (deps, CI, configs) |
| `perf` | Mejora de rendimiento |

**Scopes comunes:** `auth`, `home`, `map`, `events`, `profile`, `search`, `core`, `ci`

**Ejemplos:**
```
feat(auth): add social login buttons
fix(map): prevent crash on missing coordinates
refactor(home): extract category list to shared constants
chore(ci): add flutter analyze to GitHub Actions
```

## Estilo de codigo

- Seguimos las reglas de `very_good_analysis` (ver `analysis_options.yaml`).
- `flutter analyze` debe pasar con **0 issues** antes de cada PR.
- Nombrar archivos en `snake_case`.
- Nombrar clases en `PascalCase`.
- Nombrar variables y funciones en `camelCase`.
- Maximo 80 caracteres por linea (recomendado, no forzado).
- Documentar clases publicas con `///` doc comments.

## Variables de entorno

- **NUNCA** commitear `.env`, `.jks`, o `key.properties`.
- Copiar `.env.example` a `.env` para desarrollo local.
- Los secretos se inyectan via `--dart-define` en CI/CD.

## Estructura de features

Cada feature sigue la estructura:
```
lib/features/<feature>/
  |- domain/          # Entidades, contratos, use cases
  |- data/            # Implementaciones, DTOs, datasources
  |- presentation/    # Screens, widgets, providers
```
