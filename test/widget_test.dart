import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart' as main_app;
import '../lib/screens/galaga_game.dart';

void main() {
  group('Galaga Game Tests', () {
    testWidgets('Game initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: GalagaGame()));
      await tester.pumpAndSettle();

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
    });

    testWidgets('Pause functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: GalagaGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      expect(find.text('PAUSED'), findsOneWidget);
    });

    testWidgets('Menu navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(main_app.MyApp());
      await tester.pumpAndSettle();

      expect(find.text('GALAGA'), findsOneWidget);
      expect(find.text('START GAME'), findsOneWidget);

      await tester.tap(find.text('START GAME'));
      await tester.pumpAndSettle();

      expect(find.byType(GalagaGame), findsOneWidget);
    });
  });
}
