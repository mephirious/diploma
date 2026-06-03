import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget test harness smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('ZhamSpace')),
      ),
    );

    expect(find.text('ZhamSpace'), findsOneWidget);
  });
}
