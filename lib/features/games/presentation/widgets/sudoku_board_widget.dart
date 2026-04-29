import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/sudoku_provider.dart';

class SudokuBoardWidget extends ConsumerWidget {
  const SudokuBoardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sudokuState = ref.watch(sudokuProvider);
    final notifier = ref.read(sudokuProvider.notifier);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final value = sudokuState.currentBoard[row][col];
            final isInitial = sudokuState.puzzleBoard[row][col] != 0;
            final isSelected = sudokuState.selectedRow == row && sudokuState.selectedCol == col;
            final isRelated = sudokuState.selectedRow == row || sudokuState.selectedCol == col;

            return GestureDetector(
              onTap: () => notifier.selectCell(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : isRelated
                          ? Colors.blue.withOpacity(0.05)
                          : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: (row + 1) % 3 == 0 && row != 8 ? 2 : 0.5,
                    ),
                    right: BorderSide(
                      color: Colors.black,
                      width: (col + 1) % 3 == 0 && col != 8 ? 2 : 0.5,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    value == 0 ? '' : value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                      color: isInitial ? Colors.black : Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
