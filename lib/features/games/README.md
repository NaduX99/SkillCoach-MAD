# Interactive Games Feature

This directory handles the interactive Sudoku game challenge.

## Components & Architecture

*   **`lib/features/games/presentation/providers/sudoku_provider.dart`**: Manages the game state, including the board, selected cells, and move validation logic using Riverpod.
*   **`lib/features/games/presentation/widgets/sudoku_board_widget.dart`**: An interactive 9x9 grid component for the Sudoku board.
*   **`lib/features/games/presentation/screens/sudoku_gameplay_screen.dart`**: The main gameplay screen featuring the board and a numeric keypad for user input.
*   **`lib/core/services/sudoku_engine.dart`**: Core logic for generating and validating Sudoku puzzles.

## Key Features

- **Puzzle Generation**: Generates valid 9x9 Sudoku grids with different difficulty levels.
- **Interactive Gameplay**: Tap to select cells and input numbers via the numeric keypad.
- **Validation**: Real-time validation of moves against Sudoku rules.
- **Win Condition**: Automatic detection when the puzzle is correctly completed.
