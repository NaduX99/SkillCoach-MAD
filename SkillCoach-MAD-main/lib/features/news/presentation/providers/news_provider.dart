import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/models/news_article.dart';

class NewsNotifier extends StateNotifier<List<NewsArticle>> {
  NewsNotifier() : super(_initialNews);

  static final List<NewsArticle> _initialNews = [
    NewsArticle(
      title: 'AI BREAKTHROUGH: GEMINI 1.5 PRO',
      category: 'ARTIFICIAL INTELLIGENCE',
      description: 'Google DeepMind reveals massive context window upgrades, allowing AI to analyze multi-million line codebases in seconds. This marks a paradigm shift in personalized technical coaching.',
      icon: PhosphorIcons.cpu(PhosphorIconsStyle.fill),
      color: const Color(0xFF3B82F6),
      date: '2 hours ago',
      readTime: '4 min read',
      url: 'https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/',
    ),
    NewsArticle(
      title: 'GLOBAL EDUCATION REVOLUTION',
      category: 'WORLD NEWS',
      description: 'UNESCO reports a 40% surge in AI-augmented learning platform adoption across primary and secondary education. Digital literacy is now ranked as the #1 priority for future-ready syllabi.',
      icon: PhosphorIcons.globe(PhosphorIconsStyle.fill),
      color: const Color(0xFF10B981),
      date: '5 hours ago',
      readTime: '6 min read',
      url: 'https://www.unesco.org/en/articles/guidance-generative-ai-education-and-research',
    ),
    NewsArticle(
      title: 'THE RISE OF MICRO-LEARNING',
      category: 'LEARNING TRENDS',
      description: 'Neuroscience studies confirm that 5-15 minute learning "sprints" result in 30% higher retention rates than traditional lectures. SkillCoachR is officially adopting the Sprint-Logic protocol.',
      icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill),
      color: const Color(0xFFF59E0B),
      date: 'Yesterday',
      readTime: '3 min read',
      url: 'https://www.elearningguild.com/insights/201/microlearning-is-it-the-learning-trend-for-2024/',
    ),
    NewsArticle(
      title: 'NEURAL-SYNC TECHNOLOGY TESTING',
      category: 'TECH INNOVATION',
      description: 'Experimental haptic and VR learning environments are showing promise in accelerating physical skill acquisition by bridging the gap between digital theory and muscle memory.',
      icon: PhosphorIcons.atom(PhosphorIconsStyle.fill),
      color: const Color(0xFF8B5CF6),
      date: '2 days ago',
      readTime: '8 min read',
      url: 'https://www.wired.com/story/vr-haptics-learning-future/',
    ),
  ];
}

final newsProvider = StateNotifierProvider<NewsNotifier, List<NewsArticle>>((ref) {
  return NewsNotifier();
});
