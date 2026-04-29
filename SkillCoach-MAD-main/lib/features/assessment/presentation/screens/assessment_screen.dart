import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/assessment_provider.dart';
import '../widgets/rating_slider.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';

class AssessmentScreen extends ConsumerWidget {
  const AssessmentScreen({super.key});

  String _getSkillLevelString(int rating) {
    if (rating == 1) return 'Beginner';
    if (rating <= 3) return 'Intermediate';
    if (rating == 4) return 'Advanced';
    return 'Expert';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsyncValue = ref.watch(assessmentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(PhosphorIcons.caretLeft(), color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Skill Assessment',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Rate your current skill level',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE), // Light blue background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.brain(),
                    color: const Color(0xFF3B82F6), // Blue brain icon
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: skillsAsyncValue.when(
        data: (skills) {
          if (skills.isEmpty) {
            return const Center(child: Text('No skills found.'));
          }

          int completedSkills = skills.where((s) => s.currentRating > 1).length;
          double progress = skills.isNotEmpty ? completedSkills / skills.length : 0.0;
          
          // Minimum visible progress for visual
          if (progress < 0.05) progress = 0.05;

          return AestheticBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar Section
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$completedSkills/${skills.length} skills',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)), // Dark blue
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Avatar Cluster
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFDBEAFE), // Light blue background
                              ),
                              child: Icon(
                                PhosphorIcons.users(PhosphorIconsStyle.bold),
                                size: 48,
                                color: const Color(0xFF3B82F6), // Blue users icon
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981), // Green
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  PhosphorIcons.trendUp(PhosphorIconsStyle.bold),
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // AI Coach Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F9FF),
                          border: Border.all(color: const Color(0xFFD6E4F8)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6FB1FC), Color(0xFF1C5CE5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'AI Coach',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(PhosphorIcons.dotsThree(), color: const Color(0xFF00C7D4), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Be honest with your self-assessment. This helps me create the perfect learning path for you!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF334155),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Skills List
                      ...skills.map((skill) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      skill.name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _getSkillLevelString(skill.currentRating),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              RatingSlider(
                                currentRating: skill.currentRating,
                                onChanged: (newRating) {
                                  ref.read(assessmentProvider.notifier).updateSkillRating(skill.id, newRating);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(assessmentProvider.notifier).submitAssessment().then((_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assessment Saved! Generating Gap Analysis...')),
                        );
                        context.push('/gap-analysis');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3265D6), // Dark blue
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Analyze My Skills',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

