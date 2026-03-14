import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:que_se_hace/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: QueSeHaceApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('¡Qué se hace!'), findsOneWidget);
  });
}
