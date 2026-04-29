class SkillModel {
  final String id;
  final String name;
  final String category;
  final int currentRating;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    this.currentRating = 1,
  });

  SkillModel copyWith({
    String? id,
    String? name,
    String? category,
    int? currentRating,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentRating: currentRating ?? this.currentRating,
    );
  }

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      currentRating: json['currentRating'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'currentRating': currentRating,
    };
  }
}
