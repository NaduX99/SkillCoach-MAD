import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';
import '../providers/sudoku_provider.dart';
import '../widgets/sudoku_board_widget.dart';

class SudokuGameplayScreen extends ConsumerWidget {
  const SudokuGameplayScreen({Key? key}) : super(key: key);

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sudokuProvider);
    final notifier = ref.read(sudokuProvider.notifier);

    // Show victory dialog when game is over
    if (state.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(context, state, notifier);
      });
    }

    return Scaffold(
      body: AestheticBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildHeader(context, notifier),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      icon: PhosphorIcons.clock(),
                      value: _formatTime(state.timerSeconds),
                      label: 'Time',
                    ),
                    _buildStatItem(
                      icon: PhosphorIcons.lightbulb(),
                      value: state.hintsUsed.toString(),
                      label: 'Hints',
                    ),
                    _buildStatItem(
                      icon: PhosphorIcons.chartBar(),
                      value: state.difficulty.toUpperCase(),
                      label: 'Level',
                    ),
                  ],
                ),
              ),
              const SudokuBoardWidget(),
              const Spacer(),
              _buildNumericKeypad(notifier),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: PhosphorIcons.eraser(),
                    label: 'Clear',
                    onTap: () => notifier.clearCell(),
                  ),
                  _buildActionButton(
                    icon: PhosphorIcons.lightbulb(PhosphorIconsStyle.fill),
                    label: 'Hint',
                    onTap: () => notifier.useHint(),
                  ),
                  _buildActionButton(
                    icon: PhosphorIcons.arrowsCounterClockwise(),
                    label: 'New Game',
                    onTap: () => _showDifficultyMenu(context, notifier),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SudokuNotifier notifier) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'SUDOKU',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(PhosphorIcons.gear(), color: const Color(0xFF1E293B)),
              onPressed: () => _showDifficultyMenu(context, notifier),
            ),
          ],
        ),
      ),
    );
  }

  void _showVictoryDialog(BuildContext context, SudokuState state, SudokuNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'VICTORY!',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Color(0xFFF59E0B)),
              const SizedBox(height: 16),
              Text(
                'Puzzle Completed Successfully',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _dialogStat('Time', _formatTime(state.timerSeconds)),
                  _dialogStat('Hints', state.hintsUsed.toString()),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                notifier.resetGame(state.difficulty);
                Navigator.pop(context);
              },
              child: Text(
                'Play Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF3265D6)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3265D6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Exit',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
      ],
    );
  }

  void _showDifficultyMenu(BuildContext context, SudokuNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Difficulty',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _difficultyOption(context, notifier, 'Easy', const Color(0xFF10B981)),
              _difficultyOption(context, notifier, 'Medium', const Color(0xFFF59E0B)),
              _difficultyOption(context, notifier, 'Hard', const Color(0xFFEF4444)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _difficultyOption(BuildContext context, SudokuNotifier notifier, String label, Color color) {
    return ListTile(
      onTap: () {
        notifier.resetGame(label.toLowerCase());
        Navigator.pop(context);
      },
      leading: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildNumericKeypad(SudokuNotifier notifier) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(9, (index) {
        final number = index + 1;
        return InkWell(
          onTap: () => notifier.inputNumber(number),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF64748B)),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
