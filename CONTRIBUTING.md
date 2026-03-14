# Guía de contribución — k-hace

¡Gracias por querer contribuir a **k-hace**! Lee esta guía antes de abrir un PR.

---

## 📌 Estrategia de branches

```
main
 └── develop
      ├── feature/<nombre-corto>
      ├── fix/<nombre-corto>
      └── chore/<nombre-corto>
```

| Branch | Propósito |
|--------|-----------|
| `main` | Producción estable. Solo recibe merges desde `develop` mediante PR revisado. |
| `develop` | Integración continua. Base para todas las features. |
| `feature/*` | Una funcionalidad nueva por branch. Se mergea a `develop`. |
| `fix/*` | Correcciones de bugs. Se mergea a `develop` (o directamente a `main` si es hotfix). |
| `chore/*` | Tareas de mantenimiento (CI, deps, docs). |

### Flujo de trabajo

```bash
# Crear una nueva feature
git checkout develop
git pull origin develop
git checkout -b feature/mi-feature

# … hacer commits …

# Pushear y abrir PR hacia develop
git push origin feature/mi-feature
```

---

## ✍️ Commits convencionales

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<ámbito opcional>): <descripción corta>

[cuerpo opcional]

[footer(s) opcional(es)]
```

### Tipos permitidos

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Solo documentación |
| `style` | Formato, sin cambios de lógica |
| `refactor` | Reestructuración sin feat/fix |
| `test` | Añadir o corregir tests |
| `chore` | Tareas de build, CI, dependencias |
| `perf` | Mejora de rendimiento |

### Ejemplos

```
feat(auth): add Google Sign-In flow
fix(profile): correct List.from() type cast
chore(ci): add flutter analyze step
docs: update README setup section
```

---

## 🔍 Estilo de código

- Sigue las reglas definidas en `analysis_options.yaml` (`very_good_analysis`).
- Ejecuta `flutter analyze` antes de hacer push — **0 errors, 0 warnings** son obligatorios.
- Formatea con `dart format .` antes de hacer commit.
- Longitud máxima de línea: **120 caracteres**.

---

## 🧪 Tests

- Todo código nuevo debe tener tests unitarios o de widget correspondientes.
- Ejecuta `flutter test` para verificar que todos los tests pasan.
- Los tests viven en `test/` respetando la estructura de `lib/`.

---

## 🔒 Secretos

- **Nunca** incluyas API keys, tokens ni credenciales en el código fuente.
- Usa siempre `--dart-define` y el archivo `.env` (que está en `.gitignore`).
- Ver `.env.example` para las variables necesarias.

---

## 🔄 Proceso de PR

1. Abre el PR hacia `develop` (o `main` solo para hotfixes críticos).
2. El título del PR debe seguir el formato de Conventional Commits.
3. Descripción clara de qué cambia y por qué.
4. El CI debe estar en verde (analyze + test).
5. Al menos 1 revisión aprobada antes del merge.
6. Usa **Squash and Merge** para mantener un historial limpio en `develop`.
