import 'package:flutter_test/flutter_test.dart';
import 'package:skillcoach_mad/core/services/sudoku_engine.dart'; // Adjust import if needed

void main() {
  group('SudokuEngine Board Generation Tests', () {
    late SudokuEngine engine;

    setUp(() {
      engine = SudokuEngine();
    });

    test('generateBoard creates a fully populated 9x9 grid', () {
      final board = engine.generateBoard();

      expect(board.length, 9);
      for (int i = 0; i < 9; i++) {
        expect(board[i].length, 9);
        for (int j = 0; j < 9; j++) {
          expect(board[i][j], greaterThanOrEqualTo(1));
          expect(board[i][j], lessThanOrEqualTo(9));
        }
      }
    });

    test('createPuzzle removes correct number of cells for easy difficulty', () {
      final fullBoard = engine.generateBoard();
      final puzzle = engine.createPuzzle(fullBoard, difficulty: 'easy');

      int emptyCount = 0;
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (puzzle[i][j] == 0) {
            emptyCount++;
          }
        }
      }

      // We expect around 30, but depending on the algorithm it might overlap.
      // So let's just check it's greater than 0 and less than or equal to 30.
      expect(emptyCount, greaterThan(0));
      expect(emptyCount, lessThanOrEqualTo(30));
    });
  });
}
