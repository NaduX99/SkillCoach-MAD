import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupState {
  final String? education;
  final String? goals;
  final String? interests;

  ProfileSetupState({this.education, this.goals, this.interests});

  ProfileSetupState copyWith({String? education, String? goals, String? interests}) {
    return ProfileSetupState(
      education: education ?? this.education,
      goals: goals ?? this.goals,
      interests: interests ?? this.interests,
    );
  }
}

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  ProfileSetupNotifier() : super(ProfileSetupState());

  void setEducation(String education) {
    state = state.copyWith(education: education);
  }

  void setGoals(String goals) {
    state = state.copyWith(goals: goals);
  }

  void setInterests(String interests) {
    state = state.copyWith(interests: interests);
  }
}

final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier();
});
