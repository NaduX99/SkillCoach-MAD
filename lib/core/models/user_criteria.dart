class UserCriteria {
  final String? name;
  final String? education;
  final String? experienceLevel;
  final String? careerGoal;
  final double? weeklyHours;
  final List<String>? interests;

  UserCriteria({
    this.name,
    this.education,
    this.experienceLevel,
    this.careerGoal,
    this.weeklyHours,
    this.interests,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'education': education,
    'experienceLevel': experienceLevel,
    'careerGoal': careerGoal,
    'weeklyHours': weeklyHours,
    'interests': interests,
  };

  factory UserCriteria.fromJson(Map<String, dynamic> json) => UserCriteria(
    name: json['name'] as String?,
    education: json['education'] as String?,
    experienceLevel: json['experienceLevel'] as String?,
    careerGoal: json['careerGoal'] as String?,
    weeklyHours: (json['weeklyHours'] as num?)?.toDouble(),
    interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );

  UserCriteria copyWith({
    String? name,
    String? education,
    String? experienceLevel,
    String? careerGoal,
    double? weeklyHours,
    List<String>? interests,
  }) => UserCriteria(
    name: name ?? this.name,
    education: education ?? this.education,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    careerGoal: careerGoal ?? this.careerGoal,
    weeklyHours: weeklyHours ?? this.weeklyHours,
    interests: interests ?? this.interests,
  );

  @override
  String toString() {
    return 'UserCriteria(name: $name, education: $education, experienceLevel: $experienceLevel, careerGoal: $careerGoal, weeklyHours: $weeklyHours)';
  }
}
