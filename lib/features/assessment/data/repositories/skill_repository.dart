import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../domain/models/skill_model.dart';

part 'skill_repository.g.dart';

abstract class SkillRepository {
  Future<List<SkillModel>> getSkillsToAssess(String? careerGoal);
  Future<void> submitAssessment(List<SkillModel> assessedSkills);
}

class FakeSkillRepository implements SkillRepository {
  @override
  Future<List<SkillModel>> getSkillsToAssess(String? careerGoal) async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    List<SkillModel> skills = [];

    switch (careerGoal) {
      case 'UI/UX Designer':
        skills = [
          const SkillModel(id: 'ux1', name: 'User Research', category: 'Design'),
          const SkillModel(id: 'ux2', name: 'Wireframing', category: 'Design'),
          const SkillModel(id: 'ux3', name: 'Prototyping', category: 'Design'),
          const SkillModel(id: 'ux4', name: 'Figma Mastery', category: 'Tools'),
          const SkillModel(id: 'ux5', name: 'Interaction Design', category: 'Design'),
          const SkillModel(id: 'ux6', name: 'Visual Design', category: 'Design'),
        ];
        break;
      case 'Frontend Developer':
        skills = [
          const SkillModel(id: 'fe1', name: 'Flutter UI', category: 'Frontend Development'),
          const SkillModel(id: 'fe2', name: 'State Management', category: 'Frontend Development'),
          const SkillModel(id: 'fe3', name: 'Dart Programming', category: 'Core Language'),
          const SkillModel(id: 'fe4', name: 'API Integration', category: 'Backend Integration'),
          const SkillModel(id: 'fe5', name: 'Responsive Design', category: 'Design'),
          const SkillModel(id: 'fe6', name: 'Animations', category: 'Frontend Development'),
        ];
        break;
      case 'Backend Developer':
        skills = [
          const SkillModel(id: 'be1', name: 'API Design', category: 'Backend Development'),
          const SkillModel(id: 'be2', name: 'Database Architecture', category: 'Database'),
          const SkillModel(id: 'be3', name: 'Authentication', category: 'Security'),
          const SkillModel(id: 'be4', name: 'Server Deployment', category: 'DevOps'),
          const SkillModel(id: 'be5', name: 'Firebase', category: 'Cloud'),
          const SkillModel(id: 'be6', name: 'Node.js', category: 'Backend Language'),
        ];
        break;
      case 'Full Stack Developer':
        skills = [
          const SkillModel(id: 'fs1', name: 'Frontend Frameworks', category: 'Frontend Development'),
          const SkillModel(id: 'fs2', name: 'Backend APIs', category: 'Backend Development'),
          const SkillModel(id: 'fs3', name: 'Database Management', category: 'Database'),
          const SkillModel(id: 'fs4', name: 'Cloud Services', category: 'DevOps'),
          const SkillModel(id: 'fs5', name: 'System Architecture', category: 'Architecture'),
          const SkillModel(id: 'fs6', name: 'Version Control', category: 'Tools'),
        ];
        break;
      case 'Data Scientist':
        skills = [
          const SkillModel(id: 'ds1', name: 'Python Programming', category: 'Core Language'),
          const SkillModel(id: 'ds2', name: 'Machine Learning', category: 'AI/ML'),
          const SkillModel(id: 'ds3', name: 'Data Visualization', category: 'Data Analysis'),
          const SkillModel(id: 'ds4', name: 'Statistical Analysis', category: 'Math'),
          const SkillModel(id: 'ds5', name: 'SQL & Databases', category: 'Database'),
          const SkillModel(id: 'ds6', name: 'Deep Learning', category: 'AI/ML'),
        ];
        break;
      case 'Product Manager':
        skills = [
          const SkillModel(id: 'pm1', name: 'Product Strategy', category: 'Management'),
          const SkillModel(id: 'pm2', name: 'Agile Methodologies', category: 'Process'),
          const SkillModel(id: 'pm3', name: 'User Interviews', category: 'Research'),
          const SkillModel(id: 'pm4', name: 'Data Analytics', category: 'Data'),
          const SkillModel(id: 'pm5', name: 'Roadmapping', category: 'Strategy'),
          const SkillModel(id: 'pm6', name: 'Stakeholder Management', category: 'Communication'),
        ];
        break;
      default:
        skills = [
          const SkillModel(id: '1', name: 'Problem Solving', category: 'Soft Skills'),
          const SkillModel(id: '2', name: 'Communication', category: 'Soft Skills'),
          const SkillModel(id: '3', name: 'Time Management', category: 'Soft Skills'),
          const SkillModel(id: '4', name: 'Adaptability', category: 'Soft Skills'),
          const SkillModel(id: '5', name: 'Teamwork', category: 'Soft Skills'),
          const SkillModel(id: '6', name: 'Critical Thinking', category: 'Soft Skills'),
        ];
    }

    return skills;
  }

  @override
  Future<void> submitAssessment(List<SkillModel> assessedSkills) async {
    // Simulated network delay
    await Future.delayed(const Duration(seconds: 1));
    // Here it would send the updated ratings to Firebase
    debugPrint('Submitted skills: ${assessedSkills.map((s) => '${s.name}: ${s.currentRating}')}');
  }
}

@riverpod
SkillRepository skillRepository(Ref ref) {

  // Return the fake implementation until Firebase is integrated
  return FakeSkillRepository();
}
