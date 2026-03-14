#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Generador base de Golden Tests para widgets y pantallas
# Ejecutar: bash .github/scripts/generate-golden-tests.sh <ruta_widget>
# Ejemplo:  bash .github/scripts/generate-golden-tests.sh lib/features/auth/presentation/widgets/auth_login_content.dart
# ─────────────────────────────────────────────────────────────────────────────

set -e

if [ -z "$1" ]; then
  echo "Uso: bash .github/scripts/generate-golden-tests.sh <ruta_archivo.dart>"
  echo "Ejemplo: bash .github/scripts/generate-golden-tests.sh lib/features/auth/presentation/widgets/auth_login_content.dart"
  exit 1
fi

SOURCE_FILE="$1"

if [ ! -f "$SOURCE_FILE" ]; then
  echo "❌ Archivo no encontrado: $SOURCE_FILE"
  exit 1
fi

# Derivar rutas
RELATIVE_PATH="${SOURCE_FILE#lib/}"
TEST_DIR="test/${RELATIVE_PATH%/*}"
FILENAME=$(basename "$SOURCE_FILE" .dart)
TEST_FILE="$TEST_DIR/${FILENAME}_golden_test.dart"
GOLDENS_DIR="$TEST_DIR/goldens"

# Extraer nombre de clase (primer match de 'class X extends/with')
CLASS_NAME=$(grep -oP 'class \K[A-Za-z0-9_]+(?=\s+(extends|with))' "$SOURCE_FILE" | head -1)

if [ -z "$CLASS_NAME" ]; then
  echo "⚠️  No se encontró una clase widget en $SOURCE_FILE"
  echo "Se generará el archivo con un placeholder."
  CLASS_NAME="WidgetBajoTest"
fi

# Crear directorios
mkdir -p "$TEST_DIR"
mkdir -p "$GOLDENS_DIR"

# Generar archivo de golden test
if [ -f "$TEST_FILE" ]; then
  echo "⚠️  El archivo ya existe: $TEST_FILE"
  echo "No se sobreescribirá."
  exit 0
fi

cat > "$TEST_FILE" << DART
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:que_se_hace/$RELATIVE_PATH';

// Golden tests para $CLASS_NAME
// Generar goldens: flutter test --update-goldens $TEST_FILE
// Verificar:       flutter test $TEST_FILE

void main() {
  group('$CLASS_NAME Golden Tests', () {
    Widget buildTestWidget({Size size = const Size(375, 812)}) {
      return MaterialApp(
        theme: ThemeData.dark(), // Ajustar al theme real (AppTheme)
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(
            body: const $CLASS_NAME(
              // TODO: Pasar parámetros requeridos del widget
            ),
          ),
        ),
      );
    }

    testWidgets('mobile portrait', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType($CLASS_NAME),
        matchesGoldenFile('goldens/${FILENAME}_mobile.png'),
      );
    });

    testWidgets('tablet landscape', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(size: const Size(1024, 768)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType($CLASS_NAME),
        matchesGoldenFile('goldens/${FILENAME}_tablet.png'),
      );
    });

    testWidgets('large font accessibility', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              textScaler: TextScaler.linear(1.5),
            ),
            child: Scaffold(
              body: const $CLASS_NAME(
                // TODO: Pasar parámetros requeridos del widget
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType($CLASS_NAME),
        matchesGoldenFile('goldens/${FILENAME}_large_font.png'),
      );
    });
  });
}
DART

echo "✅ Golden test generado: $TEST_FILE"
echo "📁 Directorio de goldens: $GOLDENS_DIR"
echo ""
echo "Próximos pasos:"
echo "  1. Edita $TEST_FILE para pasar los parámetros correctos al widget"
echo "  2. Genera las imágenes base: flutter test --update-goldens $TEST_FILE"
echo "  3. Verifica: flutter test $TEST_FILE"
