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
- **Hint System**: Real-time logic to reveal correct numbers when stuck, tracking hint usage in the session stats.
- **Gameplay Timer**: Integrated timer to track session duration, displayed prominently in the UI.
- **Difficulty Settings**: Choose between Easy, Medium, and Hard modes, with the Sudoku Engine adjusting puzzle complexity accordingly.
- **Visual Feedback**: Smooth cell animations and row/column highlighting for an enhanced interactive experience.
- **Win Condition**: Automatic detection when the puzzle is correctly completed with a dedicated Victory Dialog.

## QA & Testing

- **Unit Tests**: Comprehensive tests for the Sudoku Engine (`test/sudoku_engine_test.dart`) covering board generation and rule validation.
- **Widget Tests**: UI tests for the gameplay screen and board interaction (`test/sudoku_ui_test.dart`).
- **Interactive Validation**: Real-time feedback and state management ensuring a bug-free gaming experience.

## Aesthetics

The feature uses a premium glassmorphism theme, custom Orbitron typography, and fluid cell animations to provide a modern, high-tech gaming experience.
