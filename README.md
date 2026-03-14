# k-hace 📍

> Plataforma móvil independiente para descubrir eventos, lugares y planes en tu ciudad.

**Fundadores:** Daniel Gómez · Fernando Gómez · David Novoa

---

## 📋 Tabla de contenidos

- [Descripción](#descripción)
- [Arquitectura](#arquitectura)
- [Características](#características)
- [Requisitos](#requisitos)
- [Configuración del entorno](#configuración-del-entorno)
- [Ejecución](#ejecución)
- [Tests](#tests)
- [Variables de entorno](#variables-de-entorno)
- [Contribuir](#contribuir)

---

## Descripción

**k-hace** conecta usuarios con eventos locales, restaurantes, bares, conciertos y cualquier plan disponible en su ciudad. La app permite explorar, guardar y compartir experiencias de forma rápida e intuitiva.

---

## Arquitectura

```
lib/
├── core/
│   ├── constants/        # app_constants.dart — secrets via --dart-define
│   ├── providers/        # Riverpod providers globales
│   └── theme/            # ThemeData y estilos
├── features/
│   ├── auth/             # Autenticación (Firebase Auth)
│   ├── events/           # Listado y detalle de eventos
│   ├── profile/          # Perfil de usuario
│   └── settings/         # Ajustes de la app
└── main.dart
```

**Stack:** Flutter · Dart · Firebase (Auth, Firestore, Storage) · Riverpod · Go Router

---

## Características

- 🗺️ Exploración de eventos por ubicación
- 🔐 Autenticación con Google / email
- 👤 Perfil editable con avatar
- ⚙️ Ajustes de idioma y notificaciones
- 🎨 Tema claro / oscuro

---

## Requisitos

| Herramienta | Versión mínima |
|-------------|---------------|
| Flutter     | 3.22.x        |
| Dart        | 3.4.x         |
| Java (Android) | 17         |

---

## Configuración del entorno

1. Clona el repositorio:

```bash
git clone https://github.com/DanielGoBra/k-hace.git
cd k-hace
```

2. Copia el archivo de ejemplo y rellena los valores reales:

```bash
cp .env.example .env
# edita .env con tus API keys
```

3. Instala dependencias:

```bash
flutter pub get
```

> ⚠️ **Nunca** subas `.env`, `google-services.json` ni `GoogleService-Info.plist` al repositorio.

---

## Ejecución

```bash
# Modo desarrollo (usa variables de .env)
bash scripts/run_dev.sh

# O manualmente
flutter run \
  --dart-define=FIREBASE_API_KEY=tu_key \
  --dart-define=FIREBASE_PROJECT_ID=tu_project_id \
  --dart-define=MAPS_API_KEY=tu_maps_key
```

---

## Tests

```bash
flutter test
flutter analyze
```

---

## Variables de entorno

Ver [`.env.example`](.env.example) para la lista completa de variables necesarias.

| Variable | Descripción |
|----------|-------------|
| `FIREBASE_API_KEY` | API key del proyecto Firebase |
| `FIREBASE_PROJECT_ID` | ID del proyecto Firebase |
| `MAPS_API_KEY` | Google Maps API key |

---

## Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para conocer el flujo de trabajo, la estrategia de branches y las convenciones de commits.

