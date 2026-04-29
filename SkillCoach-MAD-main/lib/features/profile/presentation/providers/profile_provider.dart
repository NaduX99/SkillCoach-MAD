import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String name;
  final String email;
  final String avatarUrl;
  final int hoursLearned;
  final int coursesCompleted;

  ProfileState({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.hoursLearned,
    required this.coursesCompleted,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? hoursLearned,
    int? coursesCompleted,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hoursLearned: hoursLearned ?? this.hoursLearned,
      coursesCompleted: coursesCompleted ?? this.coursesCompleted,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          name: 'Lasantha',
          email: 'social.iamlasantha@gmail.com',
          avatarUrl: 'https://ui-avatars.com/api/?name=Lasantha&background=0D8ABC&color=fff',
          hoursLearned: 42,
          coursesCompleted: 7,
        ));

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
