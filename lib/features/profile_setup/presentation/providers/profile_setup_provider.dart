import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupState {
  final String? education;
  final String? experience;
  final String? goals;
  final String? interests;

  ProfileSetupState({this.education, this.experience, this.goals, this.interests});

  ProfileSetupState copyWith({String? education, String? experience, String? goals, String? interests}) {
    return ProfileSetupState(
      education: education ?? this.education,
      experience: experience ?? this.experience,
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

  void setExperience(String experience) {
    state = state.copyWith(experience: experience);
  }

  void setCareerGoal(String? goals) {
    if (goals != null) {
      state = state.copyWith(goals: goals);
    }
  }

  void setInterests(String interests) {
    state = state.copyWith(interests: interests);
  }
}

final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier();
});
