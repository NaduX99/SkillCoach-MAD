import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/app_prefs.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/models/milestone.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';
import 'dart:async';
import '../../../../core/providers/user_provider.dart';

class NewSkillScreen extends ConsumerStatefulWidget {
  const NewSkillScreen({super.key});

  @override
  ConsumerState<NewSkillScreen> createState() => _NewSkillScreenState();
}

class _NewSkillScreenState extends ConsumerState<NewSkillScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _learnedSkills = [];
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String _selectedSkill = 'Flutter';
  final TextEditingController _otherSkillController = TextEditingController();

  final List<String> _skills = [
    'Flutter',
    'AI / ML',
    'Data Science',
    'DevOps',
    'UI / UX',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(allUserSkillsProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _otherSkillController.dispose();
    super.dispose();
  }

  Future<void> _handleNewSkillAnalyze() async {
    final skill = _selectedSkill == 'Other'
        ? _otherSkillController.text.trim()
        : _selectedSkill;

    if (skill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or type a skill!')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final criteria = await AppPrefs.loadCriteria();
      final goal = criteria?.careerGoal ?? "Master $skill";

      // PERFORMANCE FIX: Added 40-second UI-level timeout fail-safe
      final milestones = await AIService.generateRoadmap(
        goal,
        skill,
        criteria: criteria,
      ).timeout(
        const Duration(seconds: 40),
        onTimeout: () => throw 'Connection timeout. Please check your internet and try again.',
      );

      await AppPrefs.save(goal, skill, milestones);

      // Invalidate to refresh all screens
      ref.invalidate(allUserSkillsProvider);
      ref.invalidate(userMilestonesProvider);
      ref.invalidate(userCurrentSkillProvider);

      if (mounted) {
        await context.push(
          '/dashboard',
          extra: {
            'goal': goal,
            'skill': skill,
            'milestones': milestones,
          },
        );
        // Note: ref.invalidate already signaled refresh, no need for manual call
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _resumeSkill(Map<String, dynamic> skillData) {
    final milestonesJson = skillData['milestones'] as List<dynamic>? ?? [];
    final milestones = milestonesJson
        .map((m) => Milestone.fromSaved((m as Map).cast<String, dynamic>()))
        .toList();

    context.push(
      '/dashboard',
      extra: {
        'goal': skillData['goal'] ?? '',
        'skill': skillData['skill'] ?? '',
        'milestones': milestones,
      },
    ).then((_) {
      if (mounted) {
        ref.invalidate(allUserSkillsProvider);
      }
    });
  }

  IconData _getSkillIcon(String skill) {
    switch (skill.toLowerCase()) {
      case 'flutter':
        return PhosphorIcons.deviceMobile();
      case 'ai / ml':
        return PhosphorIcons.brain();
      case 'data science':
        return PhosphorIcons.chartBar();
      case 'devops':
        return PhosphorIcons.gear();
      case 'ui / ux':
        return PhosphorIcons.palette();
      default:
        return PhosphorIcons.code();
    }
  }

  Widget _buildSkillSections(List<Map<String, dynamic>> skills) {
    if (skills.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(204), // 0.8 opacity
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(PhosphorIcons.sparkle(), size: 48, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              "No skills started yet.",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Text(
              "Start your first roadmap below to see your progress here!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    final inProgress = skills.where((s) {
      final ms = s['milestones'] as List<dynamic>? ?? [];
      if (ms.isEmpty) return true;
      final doneCount = ms.where((m) {
        final val = m['completed'];
        return val == true || val == 1;
      }).length;
      return doneCount < ms.length;
    }).toList();

    final completedSkills = skills.where((s) {
      final ms = s['milestones'] as List<dynamic>? ?? [];
      if (ms.isEmpty) return false;
      final doneCount = ms.where((m) {
        final val = m['completed'];
        return val == true || val == 1;
      }).length;
      return doneCount >= ms.length;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── IN PROGRESS SECTION ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text('CURRENTLY LEARNING',
              style: GoogleFonts.orbitron(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF0F172A),
                  letterSpacing: 1.5,
              )),
        ),
        if (inProgress.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFF8FAFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(PhosphorIcons.sparkle(), size: 40, color: const Color(0xFF3B82F6)),
                  const SizedBox(height: 12),
                  Text(
                    completedSkills.isNotEmpty 
                        ? 'Mastered your goals!' 
                        : 'No active roadmaps',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completedSkills.isNotEmpty
                        ? 'You\'ve finished your current path. Ready for the next challenge?'
                        : 'Start by selecting a skill below to generate an AI roadmap.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          )
        else
          ...inProgress.map((s) => _buildSkillCard(s, isCompleted: false)),

        // ── COMPLETED SECTION ────────────────────────────────────────────
        if (completedSkills.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(25), // 0.1 opacity
                    shape: BoxShape.circle,
                  ),
                  child: Icon(PhosphorIcons.trophy(PhosphorIconsStyle.fill), color: const Color(0xFF10B981), size: 16),
                ),
                const SizedBox(width: 8),
                Text('FINISHED SKILLS',
                    style: GoogleFonts.orbitron(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF0F172A),
                        letterSpacing: 1.5,
                    )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${completedSkills.length}',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                ),
              ],
            ),
          ),
          ...completedSkills.map((s) => _buildSkillCard(s, isCompleted: true)),
        ],
      ],
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill, {required bool isCompleted}) {
    final milestones = skill['milestones'] as List<dynamic>? ?? [];
    final completed = milestones.where((m) {
      final val = m['completed'];
      return val == true || val == 1;
    }).length;
    final total = milestones.length;
    final progress = total > 0 ? completed / total : 0.0;

    final iconColor = isCompleted ? const Color(0xFF10B981) : const Color(0xFF3B82F6);
    final iconBg = isCompleted
        ? const Color(0xFF10B981).withAlpha(25) // 0.1 opacity
        : const Color(0xFF3B82F6).withAlpha(25); // 0.1 opacity

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: InkWell(
        onTap: () => _resumeSkill(skill),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? const Color(0xFF10B981).withAlpha(76) : const Color(0xFFE2E8F0), // 0.3 opacity
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)), // 0.03 opacity
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(_getSkillIcon(skill['skill'] ?? ''), color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(skill['skill']?.toString().toUpperCase() ?? 'UNKNOWN',
                            style: GoogleFonts.orbitron(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.5,
                            )),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(25), // 0.1 opacity
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('✓ Done',
                              style: GoogleFonts.orbitron(
                                  fontSize: 9, 
                                  fontWeight: FontWeight.bold, 
                                  color: const Color(0xFF10B981),
                                  letterSpacing: 0.5,
                              )),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text('$completed / $total milestones',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(PhosphorIcons.caretRight(), color: const Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSkillsAsync = ref.watch(allUserSkillsProvider);
    final learnedSkills = allSkillsAsync.value ?? [];
    final isLoadingAsync = allSkillsAsync.isLoading;

    return Scaffold(
      body: AestheticBackground(
        child: SafeArea(
          child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  'MY SKILLS',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            // Skill List — split into In Progress + Completed
            if (isLoadingAsync && learnedSkills.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              SliverToBoxAdapter(
                child: _buildSkillSections(learnedSkills),
              ),


            // Divider
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Divider(color: Color(0xFFE2E8F0)),
              ),
            ),

            // New Skill Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARN A SKILL',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pick a skill and generate your AI-powered roadmap',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Skill Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSkill,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF3B82F6)),
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF0F172A), fontSize: 15),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF3B82F6)),
                        ),
                      ),
                      items: _skills.map((String skill) {
                        return DropdownMenuItem<String>(
                          value: skill,
                          child: Text(skill),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedSkill = newValue);
                        }
                      },
                    ),
                    if (_selectedSkill == 'Other') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _otherSkillController,
                        style:
                            GoogleFonts.poppins(color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Type your skill...',
                          hintStyle: GoogleFonts.poppins(
                              color: const Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Analyze Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isAnalyzing ? null : _handleNewSkillAnalyze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isAnalyzing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(PhosphorIcons.sparkle(), size: 20),
                                  const SizedBox(width: 8),
                                  Text('GENERATE ROADMAP',
                                      style: GoogleFonts.orbitron(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 1,
                                      )),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
     ),
   );
  }
}

