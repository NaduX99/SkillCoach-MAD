import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sudoku_engine.dart';

class SudokuState {
  final List<List<int>> puzzleBoard;
  final List<List<int>> currentBoard;
  final List<List<int>> fullBoard;
  final int? selectedRow;
  final int? selectedCol;
  final bool isGameOver;

  SudokuState({
    required this.puzzleBoard,
    required this.currentBoard,
    required this.fullBoard,
    this.selectedRow,
    this.selectedCol,
    this.isGameOver = false,
  });

  SudokuState copyWith({
    List<List<int>>? currentBoard,
    int? selectedRow,
    int? selectedCol,
    bool? isGameOver,
  }) {
    return SudokuState(
      puzzleBoard: puzzleBoard,
      currentBoard: currentBoard ?? this.currentBoard,
      fullBoard: fullBoard,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class SudokuNotifier extends StateNotifier<SudokuState> {
  final SudokuEngine _engine;

  SudokuNotifier(this._engine) : super(_initializeState(_engine));

  static SudokuState _initializeState(SudokuEngine engine) {
    final fullBoard = engine.generateBoard();
    final puzzleBoard = engine.createPuzzle(fullBoard, difficulty: 'easy');
    
    // Deep copy puzzleBoard to currentBoard
    final currentBoard = List.generate(9, (i) => List<int>.from(puzzleBoard[i]));

    return SudokuState(
      puzzleBoard: puzzleBoard,
      currentBoard: currentBoard,
      fullBoard: fullBoard,
    );
  }

  void selectCell(int row, int col) {
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  void inputNumber(int number) {
    if (state.selectedRow == null || state.selectedCol == null) return;
    
    int r = state.selectedRow!;
    int c = state.selectedCol!;

    // Cannot overwrite puzzle's initial clues
    if (state.puzzleBoard[r][c] != 0) return;

    if (_engine.validateMove(state.currentBoard, r, c, number)) {
      final newBoard = List.generate(9, (i) => List<int>.from(state.currentBoard[i]));
      newBoard[r][c] = number;
      
      bool gameOver = _checkWinCondition(newBoard, state.fullBoard);
      
      state = state.copyWith(currentBoard: newBoard, isGameOver: gameOver);
    }
  }

  void clearCell() {
    if (state.selectedRow == null || state.selectedCol == null) return;
    
    int r = state.selectedRow!;
    int c = state.selectedCol!;

    // Cannot clear puzzle's initial clues
    if (state.puzzleBoard[r][c] != 0) return;

    final newBoard = List.generate(9, (i) => List<int>.from(state.currentBoard[i]));
    newBoard[r][c] = 0;
    
    state = state.copyWith(currentBoard: newBoard);
  }
  
  bool _checkWinCondition(List<List<int>> current, List<List<int>> full) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (current[i][j] != full[i][j]) return false;
      }
    }
    return true;
  }
}

final sudokuProvider = StateNotifierProvider<SudokuNotifier, SudokuState>((ref) {
  final engine = SudokuEngine();
  return SudokuNotifier(engine);
});
