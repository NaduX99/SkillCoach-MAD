import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';

class NewsInsightsScreen extends StatelessWidget {
  const NewsInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsList = [
      {
        'title': 'AI BREAKTHROUGH: GEMINI 1.5 PRO',
        'category': 'ARTIFICIAL INTELLIGENCE',
        'desc': 'Google DeepMind reveals massive context window upgrades, allowing AI to analyze multi-million line codebases in seconds. This marks a paradigm shift in personalized technical coaching.',
        'icon': PhosphorIcons.cpu(PhosphorIconsStyle.fill),
        'color': const Color(0xFF3B82F6),
        'date': '2 hours ago',
        'readTime': '4 min read',
        'url': 'https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/',
      },
      {
        'title': 'GLOBAL EDUCATION REVOLUTION',
        'category': 'WORLD NEWS',
        'desc': 'UNESCO reports a 40% surge in AI-augmented learning platform adoption across primary and secondary education. Digital literacy is now ranked as the #1 priority for future-ready syllabi.',
        'icon': PhosphorIcons.globe(PhosphorIconsStyle.fill),
        'color': const Color(0xFF10B981),
        'date': '5 hours ago',
        'readTime': '6 min read',
        'url': 'https://www.unesco.org/en/articles/guidance-generative-ai-education-and-research',
      },
      {
        'title': 'THE RISE OF MICRO-LEARNING',
        'category': 'LEARNING TRENDS',
        'desc': 'Neuroscience studies confirm that 5-15 minute learning "sprints" result in 30% higher retention rates than traditional lectures. SkillCoachR is officially adopting the Sprint-Logic protocol.',
        'icon': PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill),
        'color': const Color(0xFFF59E0B),
        'date': 'Yesterday',
        'readTime': '3 min read',
        'url': 'https://www.elearningguild.com/insights/201/microlearning-is-it-the-learning-trend-for-2024/',
      },
      {
        'title': 'NEURAL-SYNC TECHNOLOGY TESTING',
        'category': 'TECH INNOVATION',
        'desc': 'Experimental haptic and VR learning environments are showing promise in accelerating physical skill acquisition by bridging the gap between digital theory and muscle memory.',
        'icon': PhosphorIcons.atom(PhosphorIconsStyle.fill),
        'color': const Color(0xFF8B5CF6),
        'date': '2 days ago',
        'readTime': '8 min read',
        'url': 'https://www.wired.com/story/vr-haptics-learning-future/',
      },
    ];

    return Scaffold(
      body: AestheticBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final news = newsList[index];
                  return _buildNewsCard(news);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                  'WORLD NEWS & AI',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Stay ahead of the learning curve',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    final color = news['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Color Strip
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        news['category'] as String,
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      news['date'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(news['icon'] as IconData, color: color, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news['title'] as String,
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            news['desc'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF475569),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.clock(), color: const Color(0xFF94A3B8), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          news['readTime'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _launchUrl(news['url'] as String),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'FULL REPORT',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(PhosphorIcons.arrowRight(), color: color, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
