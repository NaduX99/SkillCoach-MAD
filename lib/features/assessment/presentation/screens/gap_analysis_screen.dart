import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/assessment_provider.dart';

import '../../domain/models/skill_model.dart';
import '../../../profile_setup/presentation/providers/profile_setup_provider.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/app_prefs.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';
import '../../../../core/providers/user_provider.dart';


class GapAnalysisScreen extends ConsumerWidget {
  const GapAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentState = ref.watch(assessmentProvider);
    final criteria = ref.watch(profileSetupProvider);
    final careerGoal = criteria.careerGoal ?? 'your career goal';

    return Scaffold(
      body: AestheticBackground(
        child: Column(
          children: [
            // Header
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(PhosphorIcons.caretLeft(), color: Colors.black87),
                          onPressed: () => context.go('/'),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Skill Gap Analysis',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'See how you compare',
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
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.target(),
                        color: const Color(0xFF3B82F6),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: assessmentState.when(
                data: (skills) {
                  if (skills.isEmpty) {
                    return const Center(child: Text('No skill data found.'));
                  }

                  const targetRating = 4.5;
                  final criticalGaps = skills.where((s) => (targetRating - s.currentRating) >= 3).toList();
                  final List<SkillModel> sortedByGap = List<SkillModel>.from(skills)
                    ..sort((a, b) => (targetRating - b.currentRating).compareTo(targetRating - a.currentRating));
                  final nextStepSkill = sortedByGap.isNotEmpty ? sortedByGap.first : skills.first;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Insight Banner
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9).withAlpha(128), // 0.5 opacity
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withAlpha(25), // 0.1 opacity
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill), color: const Color(0xFF3B82F6), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Analysis Complete',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1E293B)),
                                    ),
                                    Text(
                                      "Your skills are compared against industry standards for $careerGoal.",
                                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Skills Comparison Title
                        Text(
                          'Skills Comparison',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Radar Chart Card
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 10)), // 0.02 opacity
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 250,
                                child: RadarChart(
                                  RadarChartData(
                                    dataSets: [
                                      RadarDataSet(
                                        fillColor: const Color(0xFF3B82F6).withAlpha(51), // 0.2 opacity
                                        borderColor: const Color(0xFF3B82F6),
                                        entryRadius: 3,
                                        dataEntries: skills.map((s) => RadarEntry(value: s.currentRating.toDouble())).toList(),
                                        borderWidth: 2,
                                      ),
                                      RadarDataSet(
                                        fillColor: const Color(0xFF94A3B8).withAlpha(13), // 0.05 opacity
                                        borderColor: const Color(0xFF94A3B8).withAlpha(76), // 0.3 opacity
                                        entryRadius: 0,
                                        dataEntries: skills.map((_) => RadarEntry(value: targetRating)).toList(),
                                        borderWidth: 1,
                                      ),
                                    ],
                                    radarBackgroundColor: Colors.transparent,
                                    borderData: FlBorderData(show: false),
                                    radarBorderData: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
                                    tickCount: 4,
                                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                                    tickBorderData: const BorderSide(color: Color(0xFFF1F5F9)),
                                    gridBorderData: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                                    radarShape: RadarShape.circle,
                                    getTitle: (index, angle) {
                                      if (index < 0 || index >= skills.length) return const RadarChartTitle(text: '');
                                      return RadarChartTitle(
                                        text: skills[index].name,
                                        angle: angle,
                                        positionPercentageOffset: 0.1,
                                      );
                                    },
                                    titleTextStyle: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem(const Color(0xFF3B82F6), 'Your Skills'),
                                  const SizedBox(width: 24),
                                  _buildLegendItem(const Color(0xFF94A3B8).withAlpha(128), 'Industry Standard'), // 0.5 opacity
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Insights
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: const Color(0xFFEF4444)),
                                    const SizedBox(height: 8),
                                    Text(
                                      criticalGaps.isNotEmpty ? 'Critical Gap' : 'On Track',
                                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFB91C1C), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      criticalGaps.isNotEmpty ? 'Focus on ${criticalGaps.first.name}' : 'Looking Good!',
                                      style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF7F1D1D), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFEFF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFA5F3FC)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill), color: const Color(0xFF06B6D4)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Next Step',
                                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0E7490), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      nextStepSkill.name,
                                      style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF164E63), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Breakdown Title
                        Text(
                          'Detailed Breakdown',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Skill List
                        ...skills.map((skill) {
                          final gap = targetRating - skill.currentRating;
                          String priorityText;
                          Color priorityColor;
                          Color priorityBg;
                          if (gap >= 2) {
                            priorityText = 'High Priority';
                            priorityColor = const Color(0xFFEF4444);
                            priorityBg = const Color(0xFFFEF2F2);
                          } else if (gap >= 1) {
                            priorityText = 'Medium Priority';
                            priorityColor = const Color(0xFFF59E0B);
                            priorityBg = const Color(0xFFFFFBEB);
                          } else {
                            priorityText = 'On Track';
                            priorityColor = const Color(0xFF10B981);
                            priorityBg = const Color(0xFFECFDF5);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _SkillBreakdownCard(
                              skillName: skill.name,
                              currentPct: skill.currentRating / 5.0,
                              targetPct: targetRating / 5.0,
                              priorityText: priorityText,
                              priorityColor: priorityColor,
                              priorityBg: priorityBg,
                              growthNeeded: gap > 0 ? (gap / 5.0 * 100).toInt() : 0,
                            ),
                          );
                        }),

                        const SizedBox(height: 32),
                        _GenerateRoadmapButton(careerGoal: careerGoal, targetSkill: nextStepSkill.name),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Icon(PhosphorIcons.caretCircleRight(PhosphorIconsStyle.fill), color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
      ],
    );
  }
}

class _SkillBreakdownCard extends StatelessWidget {
  final String skillName;
  final double currentPct;
  final double targetPct;
  final String priorityText;
  final Color priorityColor;
  final Color priorityBg;
  final int growthNeeded;

  const _SkillBreakdownCard({
    required this.skillName,
    required this.currentPct,
    required this.targetPct,
    required this.priorityText,
    required this.priorityColor,
    required this.priorityBg,
    required this.growthNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)), // 0.02 opacity
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skillName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${(currentPct * 100).toInt()}% ',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1E293B)),
                    ),
                    TextSpan(
                      text: 'vs ${(targetPct * 100).toInt()}% target',
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(20)),
            child: Text(priorityText, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 10, color: priorityColor)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Level', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
              Text('Target Level', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(5)),
              ),
              FractionallySizedBox(
                widthFactor: targetPct,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withAlpha(38), borderRadius: BorderRadius.circular(5)), // 0.15 opacity
                ),
              ),
              FractionallySizedBox(
                widthFactor: currentPct,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(PhosphorIcons.trendUp(), color: const Color(0xFF06B6D4), size: 16),
              const SizedBox(width: 6),
              Text(
                growthNeeded > 0 ? '$growthNeeded% growth needed' : 'Standard Met',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF06B6D4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenerateRoadmapButton extends ConsumerStatefulWidget {
  final String careerGoal;
  final String targetSkill;
  const _GenerateRoadmapButton({required this.careerGoal, required this.targetSkill});

  @override
  ConsumerState<_GenerateRoadmapButton> createState() => _GenerateRoadmapButtonState();
}

class _GenerateRoadmapButtonState extends ConsumerState<_GenerateRoadmapButton> {
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final goal = widget.careerGoal;
      final skill = widget.targetSkill; 
      
      final milestones = await AIService.generateRoadmap(goal, skill);
      await AppPrefs.save(goal, skill, milestones);
      
      try {
        // Invalidate to refresh profile milestones
        ref.invalidate(userMilestonesProvider);
      } catch (e) {
        debugPrint('Sync error (possibly needs restart): $e');
      }
      
      // Update profile status in Firestore
      await ref.read(authServiceProvider).completeProfile();

      if (!mounted) return;
      context.go('/dashboard', extra: {
        'goal': goal,
        'skill': skill,
        'milestones': milestones,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6), // Blue
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else ...[
              Text(
                'Generate Learning Roadmap',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(PhosphorIcons.arrowRight()),
            ],
          ],
        ),
      ),
    );
  }
}


