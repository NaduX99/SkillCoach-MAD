import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';

class QuizResultScreen extends StatefulWidget {
  final int score;
  final int correct;
  final int total;
  final String milestoneTitle;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.correct,
    required this.total,
    required this.milestoneTitle,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progressAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  bool get passed => widget.score >= 60;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _progressAnim = Tween<double>(begin: 0, end: widget.score / 100.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic)));
    _fadeAnim = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.3, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    
    return Scaffold(
      body: AestheticBackground(
        child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Top Close button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(PhosphorIcons.x(), color: const Color(0xFF1E293B)),
                    onPressed: () => Navigator.pop(context, widget.score),
                  ),
                ),
                
                const Spacer(),
                
                // Animated Score Circle
                ScaleTransition(
                  scale: _scaleAnim,
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _ScoreRingPainter(
                          progress: _progressAnim.value,
                          color: primaryColor,
                          backgroundColor: const Color(0xFFF1F5F9),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(_progressAnim.value * 100).round()}%',
                                style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Score',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Result Title
                Text(
                  passed ? 'Congratulations!' : 'Keep Practicing',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passed
                      ? 'You\'ve successfully mastered this phase.'
                      : 'You need at least 60% to pass this milestone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      const Color(0xFF10B981),
                      widget.correct.toString(),
                      'Correct',
                    ),
                    const SizedBox(width: 12),
                    _buildStatItem(
                      PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                      const Color(0xFFEF4444),
                      (widget.total - widget.correct).toString(),
                      'Incorrect',
                    ),
                    const SizedBox(width: 12),
                    _buildStatItem(
                      PhosphorIcons.brain(PhosphorIconsStyle.fill),
                      const Color(0xFF3B82F6),
                      widget.total.toString(),
                      'Total',
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Actions
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, widget.score),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: passed ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue to Roadmap',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (!passed)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: Text(
                            'Retry Quiz',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
   );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background ring
    paint.color = backgroundColor;
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}


