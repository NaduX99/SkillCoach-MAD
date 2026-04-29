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
          border: Border.all(color: const Color(0xFF1E293B), width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
            ),
            itemCount: 81,
            itemBuilder: (context, index) {
              final row = index ~/ 9;
              final col = index % 9;
              return _SudokuCell(
                row: row,
                col: col,
                value: sudokuState.currentBoard[row][col],
                isInitial: sudokuState.puzzleBoard[row][col] != 0,
                isSelected: sudokuState.selectedRow == row && sudokuState.selectedCol == col,
                isRelated: sudokuState.selectedRow == row || sudokuState.selectedCol == col,
                onTap: () => notifier.selectCell(row, col),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final int value;
  final bool isInitial;
  final bool isSelected;
  final bool isRelated;
  final VoidCallback onTap;

  const _SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    required this.isInitial,
    required this.isSelected,
    required this.isRelated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFDBEAFE).withOpacity(0.8)
              : isRelated
                  ? const Color(0xFFF1F5F9).withOpacity(0.5)
                  : Colors.white.withOpacity(0.4),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFCBD5E1),
              width: (row + 1) % 3 == 0 && row != 8 ? 2 : 0.5,
            ),
            right: BorderSide(
              color: const Color(0xFFCBD5E1),
              width: (col + 1) % 3 == 0 && col != 8 ? 2 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: AnimatedScale(
            scale: value == 0 ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
            child: Text(
              value == 0 ? '' : value.toString(),
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: isInitial ? FontWeight.bold : FontWeight.w600,
                color: isInitial ? const Color(0xFF0F172A) : const Color(0xFF2563EB),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
