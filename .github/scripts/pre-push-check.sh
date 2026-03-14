#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Pre-push check — Validación local antes de crear un PR
# Ejecutar desde la raíz del proyecto: bash .github/scripts/pre-push-check.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

echo ""
echo "══════════════════════════════════════════════════════"
echo "  🚀 Validación pre-push — ¿K hace!"
echo "══════════════════════════════════════════════════════"
echo ""

# ── 1. Formato ────────────────────────────────────────────────────────────────
echo "📐 [1/4] Verificando formato..."
dart format --set-exit-if-changed lib/ test/ || {
  echo "❌ Error de formato. Ejecuta: dart format lib/ test/"
  exit 1
}
echo "✅ Formato correcto"
echo ""

# ── 2. Análisis estático ─────────────────────────────────────────────────────
echo "🔍 [2/4] Ejecutando análisis estático..."
flutter analyze --no-pub || {
  echo "❌ Errores de análisis detectados. Revisa el output arriba."
  exit 1
}
echo "✅ Análisis limpio"
echo ""

# ── 3. Secretos hardcodeados ─────────────────────────────────────────────────
echo "🔐 [3/4] Buscando secretos hardcodeados..."
SECRETS_FOUND=0

# Patrones sospechosos en archivos Dart (excluyendo comentarios y tests)
PATTERNS="sk_live_|sk_test_|pk_live_|pk_test_|supabase_url.*=.*http|supabase_anon_key.*=|aws_access_key|aws_secret_key|Bearer [A-Za-z0-9]"

if grep -rn --include="*.dart" -E "$PATTERNS" lib/ 2>/dev/null; then
  echo "⚠️  Posibles secretos detectados en lib/. Revisa los archivos arriba."
  SECRETS_FOUND=1
fi

# Verificar que .env no está trackeado
if git ls-files --error-unmatch .env .env.dev .env.staging .env.prod 2>/dev/null; then
  echo "⚠️  Archivos .env están siendo trackeados por git. Añádelos a .gitignore."
  SECRETS_FOUND=1
fi

if [ "$SECRETS_FOUND" -eq 1 ]; then
  echo "❌ Revisa los hallazgos de seguridad antes de continuar."
  exit 1
fi
echo "✅ Sin secretos detectados"
echo ""

# ── 4. Tests ──────────────────────────────────────────────────────────────────
echo "🧪 [4/4] Ejecutando tests..."
flutter test || {
  echo "❌ Algunas pruebas fallaron."
  exit 1
}
echo "✅ Tests pasaron"
echo ""

# ── Resultado ─────────────────────────────────────────────────────────────────
echo "══════════════════════════════════════════════════════"
echo "  ✅ Todo en orden. ¡Listo para el PR!"
echo "══════════════════════════════════════════════════════"
echo ""
