class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question, required this.options,
    required this.correctIndex, required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> j) =>
      QuizQuestion(
        question:     (j['question']      ?? '').toString(),
        options:      List<String>.from(j['options'] ?? const []),
        correctIndex: (j['correct_index'] ?? 0) as int,
        explanation:  (j['explanation']   ?? '').toString(),
      );
}
