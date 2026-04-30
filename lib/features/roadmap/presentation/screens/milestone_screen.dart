import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/models/milestone.dart';
import '../../../../core/models/learning_material.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';

import '../../../quiz/presentation/screens/quiz_screen.dart';

class MilestoneScreen extends StatefulWidget {
  final String skill;
  final Milestone milestone;
  final VoidCallback onScoreUpdated;

  const MilestoneScreen({
    super.key,
    required this.skill,
    required this.milestone,
    required this.onScoreUpdated,
  });

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  bool _loadingQuiz = false;

  Future<void> _startQuiz() async {
    setState(() => _loadingQuiz = true);
    try {
      final questions =
          await AIService.generateQuiz(widget.skill, widget.milestone);
      if (!mounted) return;

      final score = await Navigator.push<int?>(
          context,
          MaterialPageRoute(
              builder: (_) => QuizScreen(
                  milestone: widget.milestone, questions: questions)));
      
      if (!mounted) return;
      if (score == null) return;

      setState(() {
        widget.milestone.score = score;
        if (score >= 60) widget.milestone.completed = true;
      });
      widget.onScoreUpdated();
      
      if (score >= 60) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingQuiz = false);
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.trim().isEmpty) return;
    try {
      await launchUrl(Uri.parse(url.trim()),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.milestone;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(), color: const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MILESTONE DETAILS',
          style: GoogleFonts.orbitron(
            color: const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: AestheticBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phase Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Text(
                'PHASE ${m.index + 1}',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFF2563EB),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              m.title.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              m.description,
              style: GoogleFonts.poppins(
                color: const Color(0xFF475569),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Topics Section
            Row(
              children: [
                Icon(PhosphorIcons.listBullets(), color: const Color(0xFF3B82F6), size: 20),
                const SizedBox(width: 8),
                Text(
                  'TOPICS COVERED',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: m.topics.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  t,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),

            const SizedBox(height: 40),

            // Learning Materials Section
            Row(
              children: [
                Icon(PhosphorIcons.bookOpen(), color: const Color(0xFF3B82F6), size: 20),
                const SizedBox(width: 8),
                Text(
                  'LEARNING MATERIALS',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (m.materials.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No materials available for this phase.',
                    style: GoogleFonts.poppins(color: Colors.blueGrey, fontSize: 13),
                  ),
                ),
              )
            else
              ...m.materials.map((mat) => _buildMaterialCard(mat)),

            const SizedBox(height: 40),

            // Quiz Action Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIcons.trophy(), color: const Color(0xFF3B82F6), size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'READY FOR ASSESSMENT?',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    m.completed
                        ? 'Congratulations! You\'ve completed this phase.'
                        : 'Score 60% or higher to unlock the next phase.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  if (m.score != -1 && !m.completed)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(
                       'Last Score: ${m.score}%',
                       style: GoogleFonts.poppins(
                         color: const Color(0xFFEF4444),
                         fontWeight: FontWeight.bold,
                         fontSize: 13,
                       ),
                     ),
                   ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loadingQuiz ? null : _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _loadingQuiz
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  m.completed ? 'Retake Quiz' : 'Start Phase Quiz',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(PhosphorIcons.arrowRight(), size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!m.completed)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          widget.milestone.completed = true;
                        });
                        widget.onScoreUpdated();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: Text(
                        'Skip Phase',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
     ),
   );
  }

  Widget _buildMaterialCard(LearningMaterial mat) {
    final isVideo = mat.type.toLowerCase().contains('video');
    final ytId = extractYoutubeId(mat.url);
    
    return GestureDetector(
      onTap: () => _openUrl(mat.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8), // 0.03 opacity
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isVideo && ytId != null)
              SizedBox(
                width: double.infinity,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.video_library_rounded, color: Colors.blueGrey, size: 48),
                        ),
                      ),
                    ),
                    // Centered Play Button
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230), // 0.9 opacity
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(38), // 0.15 opacity
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF3B82F6), size: 36),
                      ),
                    ),
                    // Video Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(178), // 0.7 opacity
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Video',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isVideo ? PhosphorIcons.videoCamera() : PhosphorIcons.article(),
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mat.title,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              mat.type,
                              style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mat.isFree ? 'Free Access' : 'Paid Content',
                              style: GoogleFonts.poppins(
                                color: mat.isFree ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIcons.arrowSquareOut(), color: const Color(0xFF94A3B8), size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

