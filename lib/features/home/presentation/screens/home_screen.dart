import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/app_prefs.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/streak_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/milestone.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';
import '../../../../core/providers/user_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedSkill = 'Flutter';
  final TextEditingController _otherSkillController = TextEditingController();
  bool _isAnalyzing = false;
  int _streak = 0;
  int _completedSkillsCount = 0;
  int _activePathsCount = 0;
  String _userName = 'Learner';

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Parallelize loading skill and home data
    await Future.wait([
      _loadSavedSkill(),
      _fetchHomeData(),
    ]);
  }

  Future<void> _fetchHomeData() async {
    final results = await Future.wait([
      StreakService.loadAndUpdate(),
      AppPrefs.loadAllSkillPaths(),
    ]);

    final streak = results[0] as int;
    final allPaths = results[1] as List<Map<String, dynamic>>;

    int completed = 0;
    int active = 0;

    for (final path in allPaths) {
      final ms = path['milestones'] as List<dynamic>? ?? [];
      if (ms.isEmpty) continue;

      final doneCount = ms
          .where((m) => m['completed'] == true || m['completed'] == 1)
          .length;
      if (doneCount >= ms.length) {
        completed++;
      } else if (doneCount > 0) {
        active++;
      }
    }

    if (mounted) {
      setState(() {
        _streak = streak;
        _completedSkillsCount = completed;
        _activePathsCount = active;
      });
    }
  }

  Future<void> _loadSavedSkill() async {
    final data = await AppPrefs.load();
    if (data != null && data['skill'] != null) {
      final savedSkill = data['skill'] as String;
      if (mounted) {
        setState(() {
          if (_skills.contains(savedSkill)) {
            _selectedSkill = savedSkill;
          } else {
            _selectedSkill = 'Other';
            _otherSkillController.text = savedSkill;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _otherSkillController.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    final skill = _selectedSkill == 'Other'
        ? _otherSkillController.text.trim()
        : _selectedSkill;

    if (skill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or type a future skill!')),
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
        context.push(
          '/dashboard',
          extra: {'goal': goal, 'skill': skill, 'milestones': milestones},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AestheticBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer(
                        builder: (context, ref, child) {
                          final criteriaAsync = ref.watch(userCriteriaProvider);
                          final user = FirebaseAuth.instance.currentUser;
                          final name = (criteriaAsync.value?.name ?? user?.displayName ?? 'Learner').split(' ').first;
                          return _PremiumHeader(userName: name);
                        },
                      ),
                      const SizedBox(height: 24),
                      RepaintBoundary(
                        child: _QuickStatsBar(
                          streak: _streak,
                          completed: _completedSkillsCount,
                          active: _activePathsCount,
                        ),
                      ),
                      const SizedBox(height: 32),

                      RepaintBoundary(child: _buildAIRecommendationsShortcut()),
                      const SizedBox(height: 32),

                      const _SectionHeader(title: 'STUDY TIPS'),
                      const SizedBox(height: 16),
                      const RepaintBoundary(child: _StudyProtocolsCarousel()),
                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'Quick Actions'),
                      const SizedBox(height: 16),
                      RepaintBoundary(child: _buildActionGrid()),

                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'New Roadmap'),
                      const SizedBox(height: 16),
                      _buildSkillDropdown(),

                      if (_selectedSkill == 'Other') ...[
                        const SizedBox(height: 16),
                        _buildOtherSkillField(),
                      ],

                      const SizedBox(height: 24),
                      _buildPrimaryActionButton(),

                      const SizedBox(height: 48),
                      const _SectionHeader(title: 'BRAIN BREAK'),
                      const SizedBox(height: 16),
                      _buildBrainBreakShortcut(),

                      const SizedBox(height: 48),
                      const _SectionHeader(title: 'WORLD NEWS & AI'),
                      const SizedBox(height: 16),
                      const RepaintBoundary(child: _GlobalNewsCarousel()),

                      const SizedBox(height: 48),
                      const _BottomFooter(),
                      const SizedBox(height: 40),
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

  Widget _buildSkillDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedSkill,
          icon: Icon(
            PhosphorIcons.caretDown(),
            color: const Color(0xFF6366F1),
            size: 20,
          ),
          decoration: const InputDecoration(border: InputBorder.none),
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E293B),
            fontSize: 16,
          ),
          items: _skills.map((String skill) {
            return DropdownMenuItem<String>(value: skill, child: Text(skill));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSkill = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildOtherSkillField() {
    return TextField(
      controller: _otherSkillController,
      style: GoogleFonts.poppins(color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: 'e.g. Quantum Computing',
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _NavCard(
          title: 'Assessment',
          icon: PhosphorIcons.brain(),
          color: const Color(0xFF6366F1),
          onTap: () => context.pushNamed('assessment'),
        ),
        _NavCard(
          title: 'New Roadmap',
          icon: PhosphorIcons.sparkle(),
          color: const Color(0xFF10B981),
          onTap: _isAnalyzing ? () {} : _handleAnalyze,
        ),
        _NavCard(
          title: 'My Progress',
          icon: PhosphorIcons.chartLineUp(),
          color: const Color(0xFFF59E0B),
          onTap: () => context.go('/profile'),
        ),
        _NavCard(
          title: 'Live Chat',
          icon: PhosphorIcons.lightning(),
          color: const Color(0xFF06B6D4),
          onTap: () => context.go('/live-chat'),
        ),
      ],
    );
  }

  Widget _buildAIRecommendationsShortcut() {
    return GestureDetector(
      onTap: () => context.pushNamed('recommendations'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI PICKS',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalized resources based on your goals',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainBreakShortcut() {
    return GestureDetector(
      onTap: () => context.pushNamed('sudoku'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.brain(PhosphorIconsStyle.fill),
                color: const Color(0xFF6366F1),
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHILL ZONE',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Relax with a quick Sudoku',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Perfect for a 5-min cognitive reset',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.play(PhosphorIconsStyle.fill), color: const Color(0xFF6366F1), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _handleAnalyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _isAnalyzing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Build Roadmap',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final String userName;
  const _PremiumHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    String greeting = 'Good Morning';
    final hour = DateTime.now().hour;
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStatsBar extends StatelessWidget {
  final int streak;
  final int completed;
  final int active;

  const _QuickStatsBar({
    required this.streak,
    required this.completed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: PhosphorIcons.fire(PhosphorIconsStyle.fill),
            color: const Color(0xFFF59E0B),
            label: 'Streak',
            value: '$streak',
          ),
          const _VerticalDivider(),
          _StatItem(
            icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            color: const Color(0xFF10B981),
            label: 'Mastered',
            value: '$completed',
          ),
          const _VerticalDivider(),
          _StatItem(
            icon: PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
            color: const Color(0xFF6366F1),
            label: 'Active',
            value: '$active',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: const Color(0xFFF1F5F9));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }
}

class _StudyProtocolsCarousel extends StatelessWidget {
  const _StudyProtocolsCarousel();

  @override
  Widget build(BuildContext context) {
    final protocols = [
      {
        'title': 'ACTIVE RECALL',
        'desc': 'Test yourself immediately instead of rereading to solidify memory pathways.',
        'icon': PhosphorIcons.lightning(PhosphorIconsStyle.fill),
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'POMODORO SPRINT',
        'desc': 'Engage in 25-min high-focus bursts followed by 5-min neural resets.',
        'icon': PhosphorIcons.timer(PhosphorIconsStyle.fill),
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'FEYNMAN LOGIC',
        'desc': 'Explain concepts simply as if teaching a beginner to identify knowledge gaps.',
        'icon': PhosphorIcons.chalkboard(PhosphorIconsStyle.fill),
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'SPACED REVIEW',
        'desc': 'Review at increasing intervals to defeat the forgetting curve effectively.',
        'icon': PhosphorIcons.calendar(PhosphorIconsStyle.fill),
        'color': const Color(0xFF10B981),
      },
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: protocols.length,
        itemBuilder: (context, index) {
          final p = protocols[index];
          return Container(
            width: 240,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 16,
              right: index == protocols.length - 1 ? 24 : 0,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF312E81),
                  Color(0xFF1E1B4B),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (p['color'] as Color).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (p['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p['icon'] as IconData,
                    color: p['color'] as Color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  p['title'] as String,
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p['desc'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlobalNewsCarousel extends StatelessWidget {
  const _GlobalNewsCarousel();

  @override
  Widget build(BuildContext context) {
    final news = [
      {
        'title': 'AI BREAKTHROUGH',
        'desc': 'Gemini 1.5 Pro enables 2M token context, revolutionizing deep-skill analysis.',
        'icon': PhosphorIcons.cpu(),
        'color': const Color(0xFF3B82F6),
        'tag': 'SYSTEM UPDATE',
        'image': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&q=80&w=800',
      },
      {
        'title': 'GLOBAL EDUCATION',
        'desc': 'Digital literacy rates soar as personalized AI tutors enter 25% of top universities.',
        'icon': PhosphorIcons.globe(),
        'color': const Color(0xFF10B981),
        'tag': 'WORLD NEWS',
        'image': 'https://images.unsplash.com/photo-1501504905252-473c47e087f8?auto=format&fit=crop&q=80&w=800',
      },
      {
        'title': 'LEARNING TRENDS',
        'desc': 'Micro-learning sprints are replacing traditional 60-min lectures globally.',
        'icon': PhosphorIcons.chartLineUp(),
        'color': const Color(0xFFF59E0B),
        'tag': 'TRENDING',
        'image': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=800',
      },
      {
        'title': 'TECH INNOVATION',
        'desc': 'Neural-sync syllabi are being tested to accelerate direct skill acquisition.',
        'icon': PhosphorIcons.atom(),
        'color': const Color(0xFF8B5CF6),
        'tag': 'FUTURE-READY',
        'image': 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&q=80&w=800',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final item = news[index];
          return InkWell(
            onTap: () => context.pushNamed('news_insights'),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 300,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 16,
                right: index == news.length - 1 ? 24 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: NetworkImage(item['image'] as String),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF312E81).withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (item['color'] as Color).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1E1B4B).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (item['color'] as Color).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            item['tag'] as String,
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['desc'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomFooter extends StatelessWidget {
  const _BottomFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            height: 1,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF3B82F6).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterTag('CORE', 'ONLINE', const Color(0xFF10B981)),
              const SizedBox(width: 16),
              _buildFooterTag('RANK', 'VANGUARD', const Color(0xFFF59E0B)),
              const SizedBox(width: 16),
              _buildFooterTag('SECURE', 'LINK', const Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'SKILLCOACHR AI SYSTEM • v2.0.4-HUD',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF94A3B8),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TERMINAL SECURED • ENCRYPTED SESSION',
            style: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8).withOpacity(0.5),
              fontSize: 7,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterTag(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
