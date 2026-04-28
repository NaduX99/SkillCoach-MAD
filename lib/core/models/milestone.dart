import 'package:flutter/material.dart';
import 'learning_material.dart';

class Milestone {
  final int index;
  final String title;
  final String description;
  final List<String> topics;
  final List<LearningMaterial> materials;
  int score;
  bool completed;

  Milestone({
    required this.index,
    required this.title,
    required this.description,
    required this.topics,
    this.materials = const [],
    this.score = -1,
    this.completed = false,
  });

  factory Milestone.fromJson(Map<String, dynamic> j, int idx) {
    var mats = <LearningMaterial>[];
    if (j['materials'] is List) {
      mats = (j['materials'] as List)
          .map((m) =>
              LearningMaterial.fromJson((m as Map).cast<String, dynamic>()))
          .toList();
    }
    return Milestone(
      index: idx,
      title: (j['title'] ?? 'Milestone ${idx + 1}').toString(),
      description: (j['description'] ?? '').toString(),
      topics: List<String>.from(j['topics'] ?? const []),
      materials: mats,
    );
  }

  factory Milestone.fromSaved(Map<String, dynamic> j) => Milestone(
        index: (j['index'] ?? 0) as int,
        title: (j['title'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        topics: List<String>.from(j['topics'] ?? const []),
        materials: (j['materials'] as List? ?? [])
            .map((m) =>
                LearningMaterial.fromJson((m as Map).cast<String, dynamic>()))
            .toList(),
        score: (j['score'] ?? -1) as int,
        completed: (j['completed'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'title': title,
        'description': description,
        'topics': topics,
        'materials': materials.map((m) => m.toJson()).toList(),
        'score': score,
        'completed': completed,
      };
}

// ── Badge model ───────────────────────────────────────────────────────────
class AppBadge {
  final String label;
  final String emoji;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AppBadge({
    required this.label,
    required this.emoji,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppBadge &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}

// ── Badge computation engine ──────────────────────────────────────────────
class BadgeEngine {
  static List<AppBadge> compute(List<Milestone> milestones) {
    final badges = <AppBadge>[];
    final completed = milestones.where((m) => m.completed).length;
    final hasScore = milestones.where((m) => m.score >= 0);
    final avgScore = hasScore.isEmpty
        ? 0
        : hasScore.map((m) => m.score).reduce((a, b) => a + b) ~/
            hasScore.length;

    if (completed >= 1) {
      badges.add(const AppBadge(
        label: 'First Step',
        emoji: '🚀',
        subtitle: 'Completed first milestone',
        icon: Icons.rocket_launch_rounded,
        color: Color(0xFF3D8EFF),
      ));
    }
    if (completed >= milestones.length && milestones.isNotEmpty) {
      badges.add(const AppBadge(
        label: 'Completed!',
        emoji: '🏆',
        subtitle: 'Finished all milestones',
        icon: Icons.emoji_events_rounded,
        color: Color(0xFFFFC107),
      ));
    } else if (milestones.isNotEmpty &&
        completed >= (milestones.length / 2).ceil()) {
      badges.add(const AppBadge(
        label: 'Halfway',
        emoji: '⚡',
        subtitle: '50%+ done',
        icon: Icons.bolt_rounded,
        color: Color(0xFF00C2CB),
      ));
    }
    if (avgScore >= 90) {
      badges.add(const AppBadge(
        label: 'Top Scorer',
        emoji: '🌟',
        subtitle: 'Avg score ≥ 90%',
        icon: Icons.star_rounded,
        color: Color(0xFFFFC107),
      ));
    } else if (avgScore >= 60) {
      badges.add(const AppBadge(
        label: 'Quiz Pro',
        emoji: '🎯',
        subtitle: 'Avg score ≥ 60%',
        icon: Icons.gps_fixed_rounded,
        color: Color(0xFF4CAF50),
      ));
    }
    return badges;
  }
}
