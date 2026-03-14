#!/usr/bin/env bash
# scripts/run_dev.sh
# Ejecuta la app en modo desarrollo cargando las variables desde .env
# Uso: bash scripts/run_dev.sh [dispositivo]
#
# Requiere un archivo .env en la raíz del proyecto (ver .env.example).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌  Archivo .env no encontrado."
  echo "    Copia .env.example → .env y rellena los valores reales."
  exit 1
fi

# Carga variables del archivo .env (ignora líneas vacías y comentarios)
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

DEVICE="${1:-}"
FLUTTER_ARGS=()
if [[ -n "$DEVICE" ]]; then
  FLUTTER_ARGS+=("-d" "$DEVICE")
fi

echo "🚀  Iniciando k-hace en modo desarrollo..."
flutter run "${FLUTTER_ARGS[@]}" \
  --dart-define=FIREBASE_API_KEY="${FIREBASE_API_KEY:-}" \
  --dart-define=FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-}" \
  --dart-define=MAPS_API_KEY="${MAPS_API_KEY:-}"
