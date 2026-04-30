import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_criteria.dart';
import '../models/milestone.dart';
import '../services/app_prefs.dart';
import '../services/streak_service.dart';

/// Provides the current Firebase User and reactively updates on auth changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provides the UserCriteria for the currently logged-in user.
/// It automatically refreshes/invalidates when the auth state changes.
final userCriteriaProvider = FutureProvider<UserCriteria?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      // Load criteria from local cache or Firestore
      return await AppPrefs.loadCriteria();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provides the milestones for the currently active skill path.
final userMilestonesProvider = FutureProvider<List<Milestone>>((ref) async {
  // Watch auth state to ensure we refresh on login/logout
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return [];

  final prefs = await AppPrefs.load();
  if (prefs == null) return [];

  final milestonesJson = prefs['milestones'] as List<dynamic>? ?? [];
  return milestonesJson
      .map((m) => Milestone.fromSaved((m as Map).cast<String, dynamic>()))
      .toList();
});

/// Provides the current user's learning streak.
final userStreakProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return 0;

  return await StreakService.loadAndUpdate();
});

/// Provides the name of the currently active skill.
final userCurrentSkillProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return null;

  final prefsValue = await AppPrefs.load();
  return prefsValue?['skill'] as String?;
});

/// Provides all saved roadmap paths for the current user.
final allUserSkillsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return [];

  return await AppPrefs.loadAllSkillPaths();
});
