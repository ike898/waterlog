import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_log/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WaterLogApp()),
    );
    expect(find.text('WaterLog'), findsOneWidget);
  });
}
