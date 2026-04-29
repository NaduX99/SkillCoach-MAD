import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sudoku_engine.dart';

class SudokuState {
  final List<List<int>> puzzleBoard;
  final List<List<int>> currentBoard;
  final List<List<int>> fullBoard;
  final int? selectedRow;
  final int? selectedCol;
  final bool isGameOver;
  final int hintsUsed;
  final int timerSeconds;
  final String difficulty;

  SudokuState({
    required this.puzzleBoard,
    required this.currentBoard,
    required this.fullBoard,
    this.selectedRow,
    this.selectedCol,
    this.isGameOver = false,
    this.hintsUsed = 0,
    this.timerSeconds = 0,
    this.difficulty = 'easy',
  });

  SudokuState copyWith({
    List<List<int>>? currentBoard,
    int? selectedRow,
    int? selectedCol,
    bool? isGameOver,
    int? hintsUsed,
    int? timerSeconds,
    String? difficulty,
  }) {
    return SudokuState(
      puzzleBoard: puzzleBoard,
      currentBoard: currentBoard ?? this.currentBoard,
      fullBoard: fullBoard,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
      isGameOver: isGameOver ?? this.isGameOver,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

class SudokuNotifier extends StateNotifier<SudokuState> {
  final SudokuEngine _engine;
  Timer? _timer;

  SudokuNotifier(this._engine) : super(_initializeState(_engine)) {
    _startTimer();
  }

  static SudokuState _initializeState(SudokuEngine engine, {String difficulty = 'easy'}) {
    final fullBoard = engine.generateBoard();
    final puzzleBoard = engine.createPuzzle(fullBoard, difficulty: difficulty);
    final currentBoard = List.generate(9, (i) => List<int>.from(puzzleBoard[i]));

    return SudokuState(
      puzzleBoard: puzzleBoard,
      currentBoard: currentBoard,
      fullBoard: fullBoard,
      difficulty: difficulty,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isGameOver) {
        state = state.copyWith(timerSeconds: state.timerSeconds + 1);
      }
    });
  }

  void resetGame(String difficulty) {
    state = _initializeState(_engine, difficulty: difficulty);
    _startTimer();
  }

  void selectCell(int row, int col) {
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  void useHint() {
    if (state.isGameOver) return;
    
    // Find an empty or incorrect cell to fill
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (state.currentBoard[r][c] == 0) {
          final newBoard = List.generate(9, (i) => List<int>.from(state.currentBoard[i]));
          newBoard[r][c] = state.fullBoard[r][c];
          
          bool gameOver = _checkWinCondition(newBoard, state.fullBoard);
          state = state.copyWith(
            currentBoard: newBoard, 
            hintsUsed: state.hintsUsed + 1,
            isGameOver: gameOver,
            selectedRow: r,
            selectedCol: c,
          );
          return;
        }
      }
    }
  }

  void inputNumber(int number) {
    if (state.selectedRow == null || state.selectedCol == null || state.isGameOver) return;
    
    int r = state.selectedRow!;
    int c = state.selectedCol!;

    if (state.puzzleBoard[r][c] != 0) return;

    final newBoard = List.generate(9, (i) => List<int>.from(state.currentBoard[i]));
    newBoard[r][c] = number;
    
    bool gameOver = _checkWinCondition(newBoard, state.fullBoard);
    state = state.copyWith(currentBoard: newBoard, isGameOver: gameOver);
  }

  void clearCell() {
    if (state.selectedRow == null || state.selectedCol == null || state.isGameOver) return;
    
    int r = state.selectedRow!;
    int c = state.selectedCol!;

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sudokuProvider = StateNotifierProvider<SudokuNotifier, SudokuState>((ref) {
  final engine = SudokuEngine();
  return SudokuNotifier(engine);
});
