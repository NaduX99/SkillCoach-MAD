import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/models/milestone.dart';
import '../../../../core/models/quiz_question.dart';

import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Milestone milestone;
  final List<QuizQuestion> questions;
  
  const QuizScreen({
    super.key,
    required this.milestone,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _index = 0;
  int _correct = 0;
  int? _selected;
  bool _answered = false;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  QuizQuestion get q => widget.questions[_index];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _select(int idx) {
    if (_answered) return;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == q.correctIndex) _correct++;
    });
  }

  Future<void> _next() async {
    if (_index < widget.questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
      _slideCtrl.reset();
      _slideCtrl.forward();
    } else {
      final score = ((_correct / widget.questions.length) * 100).round();
      final result = await Navigator.push<int?>(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: score,
            correct: _correct,
            total: widget.questions.length,
            milestoneTitle: widget.milestone.title,
          ),
        ),
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / widget.questions.length;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(PhosphorIcons.x(), color: const Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Phase Assessment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    widget.milestone.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_index + 1}/${widget.questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
            minHeight: 4,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        q.question,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Options
                  SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: List.generate(q.options.length, (i) => _buildOption(i)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Explanation
                  if (_answered && q.explanation.isNotEmpty)
                    SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(PhosphorIcons.lightbulb(), color: const Color(0xFFA16207), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Explanation',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: const Color(0xFFA16207),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    q.explanation,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF713F12),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _answered ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _answered
                      ? (_index == widget.questions.length - 1 ? 'Finish Quiz' : 'Next Question')
                      : 'Select an Answer',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int i) {
    bool isCorrect = i == q.correctIndex;
    bool isSelected = i == _selected;
    
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;
    Color textColor = const Color(0xFF475569);
    Widget icon = Text(
      String.fromCharCode(65 + i),
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
    );

    if (_answered) {
      if (isCorrect) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF065F46);
        icon = Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: const Color(0xFF10B981), size: 16);
      } else if (isSelected) {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFF991B1B);
        icon = Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: const Color(0xFFEF4444), size: 16);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF3B82F6);
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1E40AF);
    }

    return GestureDetector(
      onTap: () => _select(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                q.options[i],
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

