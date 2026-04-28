import 'dart:math';

class SudokuEngine {
  final Random _random = Random();
  
  /// Generates a valid 9x9 Sudoku board
  List<List<int>> generateBoard() {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonalBlocks(board);
    _solveBoard(board);
    return board;
  }

  void _fillDiagonalBlocks(List<List<int>> board) {
    for (int i = 0; i < 9; i = i + 3) {
      _fillBlock(board, i, i);
    }
  }

  void _fillBlock(List<List<int>> board, int rowStart, int colStart) {
    int num;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        do {
          num = _random.nextInt(9) + 1;
        } while (!_isSafeInBlock(board, rowStart, colStart, num));
        board[rowStart + i][colStart + j] = num;
      }
    }
  }

  bool _isSafeInBlock(List<List<int>> board, int rowStart, int colStart, int num) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[rowStart + i][colStart + j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  bool _solveBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;
              if (_solveBoard(board)) {
                return true;
              }
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isSafe(List<List<int>> board, int row, int col, int num) {
    for (int d = 0; d < 9; d++) {
      if (board[row][d] == num) {
        return false;
      }
    }
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) {
        return false;
      }
    }
    int sqrt = 3;
    int boxRowStart = row - row % sqrt;
    int boxColStart = col - col % sqrt;

    for (int r = boxRowStart; r < boxRowStart + sqrt; r++) {
      for (int d = boxColStart; d < boxColStart + sqrt; d++) {
        if (board[r][d] == num) {
          return false;
        }
      }
    }
    return true;
  }
}
