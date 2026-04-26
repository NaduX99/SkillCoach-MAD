import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/skill_model.dart';
import '../../data/repositories/skill_repository.dart';
import '../../../../features/profile_setup/presentation/providers/profile_setup_provider.dart';

part 'assessment_provider.g.dart';

@riverpod
class Assessment extends _$Assessment {
  @override
  Future<List<SkillModel>> build() async {
    final repository = ref.watch(skillRepositoryProvider);
    final criteria = ref.watch(profileSetupProvider);
    return await repository.getSkillsToAssess(criteria.careerGoal);
  }


  void updateSkillRating(String skillId, int newRating) {
    if (state.value == null) return;
    
    final currentSkills = state.value!;
    final updatedSkills = currentSkills.map((skill) {
      if (skill.id == skillId) {
        return skill.copyWith(currentRating: newRating);
      }
      return skill;
    }).toList();

    state = AsyncData(updatedSkills);
  }

  Future<void> submitAssessment() async {
    if (state.value == null) return;
    
    // Switch to loading state or show overlay handled by UI
    final repository = ref.read(skillRepositoryProvider);
    await repository.submitAssessment(state.value!);
  }
}
