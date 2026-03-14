# ¿K hace! — Tu guia urbana inteligente

> App movil que conecta a los ciudadanos de Medellin con los mejores lugares, eventos y experiencias de la ciudad, potenciada por inteligencia artificial.

---

## Capturas de pantalla

| Auth (Dark) | Home | Mapa | Perfil |
|:-----------:|:----:|:----:|:------:|
| *coming soon* | *coming soon* | *coming soon* | *coming soon* |

---

## Arquitectura

```
lib/
 |- core/                   # Theme, router, constants, DI
 |   |- constants/
 |   |- router/
 |   |- theme/
 |- features/               # Feature-first modular structure
 |   |- auth/               # Login, registro, social auth
 |   |- events/             # Eventos de la ciudad
 |   |- home/               # Feed principal, lugares destacados
 |   |- map/                # Mapa interactivo Mapbox
 |   |- notifications/      # Centro de notificaciones
 |   |- onboarding/         # Flujo de bienvenida
 |   |- profile/            # Perfil, preferencias, settings
 |   |- search/             # Busqueda full-text
 |- shared/                 # Widgets reutilizables (15+)
```

**Stack tecnologico:**

| Capa | Tecnologia |
|------|-----------|
| Framework | Flutter 3.x (Dart ^3.9) |
| Estado | Riverpod 2.x (StateNotifier, ChangeNotifier) |
| Navegacion | GoRouter con auth guards y deep-links |
| Backend | Supabase (Auth, Database, Storage) |
| Mapas | Mapbox Maps Flutter |
| UI | Material 3, Google Fonts (Plus Jakarta Sans) |
| Tema | Dark/Light automatico (dia/noche) con override manual |

---

## Requisitos previos

- Flutter SDK >= 3.22
- Dart >= 3.9
- Android Studio o VS Code con extension Flutter
- Cuenta en [Supabase](https://supabase.com) (proyecto configurado)
- Token de [Mapbox](https://www.mapbox.com/) para el mapa

---

## Instalacion y ejecucion

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-org/que-se-hace.git
cd que-se-hace
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

```bash
cp .env.example .env
# Edita .env con tus credenciales de Supabase y Mapbox
```

### 4. Ejecutar la app

**Opcion A — Script helper (recomendado):**
```bash
bash scripts/run_dev.sh
```

**Opcion B — Manual:**
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key \
  --dart-define=MAPBOX_ACCESS_TOKEN=tu-mapbox-token
```

### 5. Build de produccion

```bash
flutter build appbundle \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=MAPBOX_ACCESS_TOKEN=...
```

---

## Features principales

- **Autenticacion unificada** — Login y registro en una sola pantalla con animaciones fluidas
- **Social login** — Google, Facebook, Apple (UI lista, backend en desarrollo)
- **Mapa interactivo** — Explora lugares con marcadores, filtros por categoria y geolocalizacion
- **Eventos** — Descubre eventos por fecha, categoria y ubicacion
- **Busqueda** — Busca lugares y eventos con filtros avanzados
- **Tema adaptativo** — Cambia automaticamente entre light/dark segun la hora del dia
- **Perfil personalizable** — Intereses, preferencias, saludo personalizado
- **Notificaciones** — Centro de notificaciones basado en preferencias

---

## Variables de entorno

| Variable | Descripcion | Requerida |
|----------|------------|:---------:|
| `SUPABASE_URL` | URL del proyecto Supabase | Si |
| `SUPABASE_ANON_KEY` | Clave publica (anon) de Supabase | Si |
| `MAPBOX_ACCESS_TOKEN` | Token de acceso de Mapbox | Si |

> **Importante:** Nunca commits el archivo `.env`. Esta incluido en `.gitignore`.

---

## Scripts utiles

| Comando | Descripcion |
|---------|------------|
| `bash scripts/run_dev.sh` | Ejecuta la app con variables desde `.env` |
| `flutter analyze` | Analisis estatico del codigo |
| `flutter test` | Ejecuta tests unitarios y de widgets |
| `flutter build appbundle` | Genera App Bundle para Play Store |

---

## Equipo

| Rol | Nombre |
|-----|--------|
| Co-Fundador & Developer | Daniel Felipe Gomez |
| Co-Fundador | Fernando Gomez |
| Co-Fundador | David Novoa |

---

## Licencia

Este proyecto es privado y confidencial. Todos los derechos reservados.
