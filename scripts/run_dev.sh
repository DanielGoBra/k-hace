#!/bin/bash
# Loads .env and runs Flutter with --dart-define for each variable.
# Usage: bash scripts/run_dev.sh [additional flutter run args]

set -e

ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Copy .env.example to .env and fill in values."
  exit 1
fi

DART_DEFINES=""
while IFS='=' read -r key value; do
  # Skip empty lines and comments
  [[ -z "$key" || "$key" == \#* ]] && continue
  DART_DEFINES="$DART_DEFINES --dart-define=$key=$value"
done < "$ENV_FILE"

echo "Running with dart-defines from $ENV_FILE..."
flutter run $DART_DEFINES "$@"
