import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillcoach_mad/features/games/presentation/screens/sudoku_gameplay_screen.dart';

void main() {
  group('Sudoku UI Widget Tests', () {
    testWidgets('SudokuGameplayScreen displays numeric keypad', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SudokuGameplayScreen(),
          ),
        ),
      );

      // Verify that numbers 1-9 are displayed in the keypad
      for (int i = 1; i <= 9; i++) {
        expect(find.text(i.toString()), findsWidgets);
      }
    });

    testWidgets('SudokuGameplayScreen displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SudokuGameplayScreen(),
          ),
        ),
      );

      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);
    });
  });
}
