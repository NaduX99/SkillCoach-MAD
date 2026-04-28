import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/app_prefs.dart';
import '../../../../core/services/streak_service.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _streak = 0;
  int _masteredSkills = 0;
  double _overallProgress = 0.0;
  List<Map<String, dynamic>> _activeSkills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final streak = await StreakService.loadAndUpdate();
      final allPaths = await AppPrefs.loadAllSkillPaths();
      
      int mastered = 0;
      double totalProgressSum = 0;
      List<Map<String, dynamic>> skillsList = [];

      for (var path in allPaths) {
        try {
          final ms = path['milestones'] as List<dynamic>? ?? [];
          if (ms.isEmpty) continue;
          
          final doneCount = ms.where((m) {
            if (m is! Map) return false;
            return m['completed'] == true || m['completed'] == 1;
          }).length;
          
          final progress = doneCount / ms.length;
          
          if (progress >= 1.0) mastered++;
          totalProgressSum += progress;
          
          skillsList.add({
            'title': path['skill'] ?? 'Skill',
            'progress': progress,
          });
        } catch (e) {
          debugPrint('Error processing skill path: $e');
        }
      }

      // Sort to show highest progress active skills first
      if (skillsList.length > 1) {
        skillsList.sort((a, b) {
          final pa = (a['progress'] as num?)?.toDouble() ?? 0.0;
          final pb = (b['progress'] as num?)?.toDouble() ?? 0.0;
          return pb.compareTo(pa);
        });
      }

      if (mounted) {
        setState(() {
          _streak = streak;
          _masteredSkills = mastered;
          _overallProgress = allPaths.isEmpty ? 0 : (totalProgressSum / allPaths.length);
          _activeSkills = skillsList.take(3).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading analytics state: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AestheticBackground(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildIdentityBadge(),
                    const SizedBox(height: 32),
                    _buildAICoachBanner(),
                    const SizedBox(height: 32),
                    _buildOverallProgressCard(),
                    const SizedBox(height: 32),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    _buildProgressTrendSection(),
                    const SizedBox(height: 48),
                    _buildSkillMasterySection(),
                    const SizedBox(height: 48),
                    _buildWeeklyTargetsSection(),
                    const SizedBox(height: 48),
                    _buildTimelineSection(),
                    const SizedBox(height: 48),
                    _buildAchievementsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(PhosphorIcons.caretLeft(), color: const Color(0xFF1E293B)),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Deep dive into your progress',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIcons.trendUp(), color: const Color(0xFF10B981), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityBadge() {
    final isMaster = _masteredSkills >= 5;
    final isIntermediate = _masteredSkills >= 1;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isMaster ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: (isMaster ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              isMaster ? PhosphorIcons.trophy(PhosphorIconsStyle.fill) : (isIntermediate ? PhosphorIcons.medal(PhosphorIconsStyle.fill) : PhosphorIcons.star(PhosphorIconsStyle.fill)),
              size: 56,
              color: isMaster ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            ),
          ),
          if (_streak > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: Text('$_streak', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAICoachBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(PhosphorIcons.robot(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Coach',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(PhosphorIcons.dotsThree(), color: const Color(0xFF166534), size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Amazing progress! You're on track to reach your goals. Your learning velocity has increased by 15% this week! 🎉",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF14532D),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(_overallProgress * 100).toInt()}',
                        style: GoogleFonts.orbitron(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, left: 4),
                        child: Text(
                          '%',
                          style: GoogleFonts.orbitron(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIcons.trendUp(PhosphorIconsStyle.bold), color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Keep up the great work!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMiniStat('${_streak}d', 'Current Streak', const Color(0xFFF59E0B), PhosphorIcons.fire()),
        _buildMiniStat('$_masteredSkills', 'Skills Mastered', const Color(0xFF10B981), PhosphorIcons.checkCircle()),
        _buildMiniStat('74%', 'Engagement', const Color(0xFF3B82F6), PhosphorIcons.chartLine()),
        _buildMiniStat('+${(_overallProgress * 10).toStringAsFixed(1)}%', 'Growth Index', const Color(0xFF8B5CF6), PhosphorIcons.trendUp()),
      ],
    );
  }

  Widget _buildMiniStat(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildProgressTrendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRESS TREND',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: const Color(0xFFF1F5F9),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                      if (value.toInt() >= 0 && value.toInt() < titles.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(titles[value.toInt()], style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 35),
                    const FlSpot(1, 48),
                    const FlSpot(2, 55),
                    const FlSpot(3, 68),
                  ],
                  isCurved: true,
                  color: const Color(0xFF3B82F6),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF3B82F6).withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillMasterySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILL MASTERY',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (_activeSkills.isEmpty)
          Text('No skills started yet.', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13))
        else
          ..._activeSkills.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSkillMasteryRow(skill['title'], skill['progress'], _getColorForSkill(skill['title'])),
          )),
      ],
    );
  }

  Color _getColorForSkill(String skill) {
    final colors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFF8B5CF6)];
    return colors[skill.length % colors.length];
  }

  Widget _buildSkillMasteryRow(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTargetsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY TARGETS',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 1,
                ),
              ),
              Text(
                '3/5 Done',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTargetItem('Complete 3 Knowledge Quizzes', true),
          _buildTargetItem('Watch 2 Advanced Tutorials', true),
          _buildTargetItem('Master "Deep Work" sessions', true),
          _buildTargetItem('Implement a custom UI theme', false),
          _buildTargetItem('Review Gap Analysis report', false),
        ],
      ),
    );
  }

  Widget _buildTargetItem(String label, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            done ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
            color: done ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: done ? const Color(0xFF64748B) : const Color(0xFF1E293B),
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    // Collect all milestones across all paths and flatten them
    final allMilestones = <Map<String, dynamic>>[];
    for (var path in _activeSkills) {
      // This is simplified; in a real app, you'd fetch the actual milestone objects
      // For now, we'll show the top active skills as 'Learning Map' points
      allMilestones.add({
        'title': path['title'],
        'status': path['progress'] >= 1.0 ? 'Completed' : 'In Progress',
        'progress': path['progress'],
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEARNING MAP',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        if (allMilestones.isEmpty)
          Text('Your learning journey starts here.', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13))
        else
          ...allMilestones.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            return _buildTimelineItem(
              'Now', 
              m['title'], 
              m['status'], 
              m['status'] == 'Completed' ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              isFirst: idx == 0,
              isLast: idx == allMilestones.length - 1,
            );
          }),
      ],
    );
  }

  Widget _buildTimelineItem(String date, String title, String status, Color color, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              date,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: status == 'Upcoming' ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACHIEVEMENTS',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: 2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF312E81), // Charm Indigo
                    Color(0xFF1E1B4B), // Deep Indigo
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
              ),
              child: Text(
                '4/12 UNLOCKED',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: const Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildAchievementCard('Week Warrior', 'Completed 7 days streak', const Color(0xFFFF6422)),
            _buildAchievementCard('Skill Master', 'Mastered 3 core skills', const Color(0xFF10B981)),
            _buildAchievementCard('Fast Learner', 'Module record time', const Color(0xFF3B82F6)),
            _buildAchievementCard('Early Bird', 'Studied before 8 AM', const Color(0xFF8B5CF6)),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(1), // Border width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF312E81), // Charm Indigo
              Color(0xFF1E1B4B), // Deep Indigo
            ],
          ),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Icon(PhosphorIcons.medal(PhosphorIconsStyle.fill), color: color, size: 28),
              ],
            ),
            const Spacer(),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: Colors.white.withOpacity(0.5),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  'COMPLETED',
                  style: GoogleFonts.orbitron(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
