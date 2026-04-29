import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/assessment/presentation/screens/assessment_screen.dart';
import '../../features/assessment/presentation/screens/gap_analysis_screen.dart';
import '../../features/games/presentation/screens/sudoku_game_screen.dart';
import '../../features/profile_setup/presentation/screens/profile_setup_screen.dart';
import '../../features/profile_setup/presentation/screens/profile_setup_step2_screen.dart';
import '../../features/profile_setup/presentation/screens/profile_setup_step3_screen.dart';
import '../../features/profile_setup/presentation/screens/profile_setup_step4_screen.dart';
import '../../features/profile_setup/presentation/screens/profile_setup_step5_screen.dart';
import '../../features/roadmap/presentation/screens/roadmap_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/roadmap/presentation/screens/new_skill_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/recommendations/presentation/screens/recommendations_screen.dart';
import '../../features/news/presentation/screens/news_insights_screen.dart';
import '../presentation/screens/main_scaffold.dart';
import '../models/milestone.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  final shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
  final shellNavigatorNewSkillKey = GlobalKey<NavigatorState>(debugLabel: 'shellNewSkill');
  final shellNavigatorChatKey = GlobalKey<NavigatorState>(debugLabel: 'shellChat');

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify_email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      // Main App Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // HOME BRANCH (Index 0)
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // CHAT BRANCH (Index 1)
          StatefulShellBranch(
            navigatorKey: shellNavigatorChatKey,
            routes: [
              GoRoute(
                path: '/live-chat',
                name: 'live_chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          // NEW SKILL BRANCH (Index 2)
          StatefulShellBranch(
            navigatorKey: shellNavigatorNewSkillKey,
            routes: [
              GoRoute(
                path: '/new-skill',
                name: 'new_skill',
                builder: (context, state) => const NewSkillScreen(),
              ),
            ],
          ),
          // PROFILE BRANCH (Index 3)
          StatefulShellBranch(
            navigatorKey: shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes (outside bottom nav)
      GoRoute(
        path: '/assessment',
        name: 'assessment',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/gap-analysis',
        name: 'gap_analysis',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GapAnalysisScreen(),
      ),
      GoRoute(
        path: '/sudoku',
        name: 'sudoku',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SudokuGameScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile_setup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/profile-setup-step2',
        name: 'profile_setup_step2',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSetupStep2Screen(),
      ),
      GoRoute(
        path: '/profile-setup-step3',
        name: 'profile_setup_step3',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSetupStep3Screen(),
      ),
      GoRoute(
        path: '/profile-setup-step4',
        name: 'profile_setup_step4',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSetupStep4Screen(),
      ),
      GoRoute(
        path: '/profile-setup-step5',
        name: 'profile_setup_step5',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSetupStep5Screen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return RoadmapScreen(
            goal: extras?['goal'] ?? '',
            skill: extras?['skill'] ?? '',
            milestones: (extras?['milestones'] as List?)?.cast<Milestone>() ?? [],
          );
        },
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/recommendations',
        name: 'recommendations',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: '/news-insights',
        name: 'news_insights',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NewsInsightsScreen(),
      ),
    ],
  );
}


