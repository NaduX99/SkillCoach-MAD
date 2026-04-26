import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/milestone.dart';
import '../models/user_criteria.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'streak_service.dart';

class AppPrefs {
  static const _baseKey = 'skillcoachr_data';
  static const _baseCriteriaKey = 'skillcoachr_criteria';

  static String _getScopedKey(String base) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null ? '${base}_$uid' : base;
  }

  static Future<void> save(
      String goal, String skill, List<Milestone> milestones) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getScopedKey(_baseKey), jsonEncode({
      'goal': goal, 'skill': skill,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    }));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final data = {
          'goal': goal, 'skill': skill,
          'milestones': milestones.map((m) => m.toJson()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        // Save as current learning path
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('progress')
            .doc('current_learning_path')
            .set(data, SetOptions(merge: true));
        // Also save to learning_paths collection for multi-skill tracking
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('learning_paths')
            .doc(skill)
            .set(data, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to sync progress to Firestore: $e');
      }
    }
  }

  /// Load all skill learning paths — checks local storage first, then Firestore
  static Future<List<Map<String, dynamic>>> loadAllSkillPaths() async {
    final results = <String, Map<String, dynamic>>{}; // keyed by skill name

    // 1. Always check local SharedPreferences first (fastest)
    final local = await load();
    if (local != null && local['skill'] != null) {
      results[local['skill'] as String] = local;
    }

    // 2. Try Firestore sources
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Check new learning_paths collection
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('learning_paths')
            .get();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['skill'] != null) {
            results[data['skill'] as String] = data;
          }
        }

        // Check old progress/current_learning_path as fallback
        if (results.isEmpty) {
          final oldDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('progress')
              .doc('current_learning_path')
              .get();
          if (oldDoc.exists && oldDoc.data() != null) {
            final data = oldDoc.data()!;
            if (data['skill'] != null) {
              results[data['skill'] as String] = data;
              // Migrate to new collection silently
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('learning_paths')
                  .doc(data['skill'] as String)
                  .set(data, SetOptions(merge: true));
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to load skill paths from Firestore: $e');
      }
    }

    return results.values.toList();
  }

  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_getScopedKey(_baseKey));
    if (saved == null) return null;
    try { return jsonDecode(saved) as Map<String, dynamic>; }
    catch (_) { return null; }
  }

  static Future<void> saveCriteria(UserCriteria criteria) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getScopedKey(_baseCriteriaKey), jsonEncode(criteria.toJson()));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'criteria': criteria.toJson(),
          'profileCompleted': true,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to sync criteria to Firestore: $e');
      }
    }
  }

  static Future<UserCriteria?> loadCriteria() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString(_getScopedKey(_baseCriteriaKey));
    
    // 1. Return local cache if available
    if (saved != null) {
      try {
        return UserCriteria.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      } catch (_) {
        // Fall through to Firestore
      }
    }

    // 2. Fallback to Firestore if local cache is empty or corrupt
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (doc.exists) {
          final docData = doc.data();
          if (docData != null && docData['criteria'] != null) {
            try {
              final data = docData['criteria'] as Map<String, dynamic>;
              // Cache locally for next time
              await prefs.setString(_getScopedKey(_baseCriteriaKey), jsonEncode(data));
              return UserCriteria.fromJson(data);
            } catch (e) {
              debugPrint('AppPrefs: Error parsing criteria from Firestore: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to load criteria from Firestore: $e');
      }
    }

    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear both global (legacy) and scoped keys for the current user
    await Future.wait([
      prefs.remove(_getScopedKey(_baseKey)),
      prefs.remove(_getScopedKey(_baseCriteriaKey)),
      // Also clear legacy keys just in case
      prefs.remove('skillcoachr_data'),
      prefs.remove('skillcoachr_criteria'),
      StreakService.clear(),
    ]);
  }
}
 
