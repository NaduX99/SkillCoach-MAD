import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_prefs.dart';

part 'auth_service.g.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Parallelize Firestore data creation, Display Name update, and Email Verification
        await Future.wait([
          _firestore.collection('users').doc(user.uid).set({
            'name': name,
            'email': email,
            'profileCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          }),
          user.updateDisplayName(name),
          user.sendEmailVerification(),
        ]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      rethrow;
    }
  }

  bool get isEmailVerified {
    final user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Parallelize independent operations:
        // 1. Get JWT Token
        // 2. Fetch User Profile from Firestore
        // 3. Initialize SharedPreferences
        final results = await Future.wait([
          user.getIdToken(),
          _firestore.collection('users').doc(user.uid).get(),
          SharedPreferences.getInstance(),
        ]);

        final token = results[0] as String?;
        final doc = results[1] as DocumentSnapshot;
        final prefs = results[2] as SharedPreferences;

        if (token != null) {
          await prefs.setString('jwt_token', token);
        }

        if (doc.exists) {
          final data = doc.data();
          if (data != null && data is Map<String, dynamic>) {
            return data['profileCompleted'] as bool? ?? false;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Login process error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove('jwt_token'),
        AppPrefs.clear(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isProfileCompleted() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return data['profileCompleted'] as bool? ?? false;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking profile completion: $e');
      return false;
    }
  }

  Future<void> completeProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'profileCompleted': true,
        });
      }
    } catch (e) {
      debugPrint('Error updating profile completion: $e');
    }
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}
