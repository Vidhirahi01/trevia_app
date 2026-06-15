class QuestionModel {
  final String id;
  final String question;
  final List<String> correctAnswers;
  final List<String> options;
  final String difficulty;
  final String category;

  QuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswers,
    required this.options,
    required this.difficulty,
    required this.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final correctAnswer = json["correctAnswer"] as String;
    final incorrectAnswers = List<String>.from(json["incorrectAnswers"]);
    final shuffledOptions = [correctAnswer, ...incorrectAnswers]..shuffle();

    return QuestionModel(
      id: json["id"] as String,
      question: _questionText(json["question"]),
      correctAnswers: [correctAnswer],
      options: shuffledOptions,
      difficulty: json["difficulty"] as String,
      category: json["category"] as String,
    );
  }

  static String _questionText(Object? question) {
    if (question is String) return question;
    if (question is Map) return question["text"] as String;
    throw const FormatException('Question text is missing from API response');
  }

  factory QuestionModel.custom({
    required String id,
    required String question,
    required List<String> options,
    required List<String> correctAnswers,
  }) {
    final shuffledOptions = [...options]..shuffle();

    return QuestionModel(
      id: id,
      question: question,
      correctAnswers: correctAnswers,
      options: shuffledOptions,
      difficulty: 'custom',
      category: 'Admin Quiz',
    );
  }

  String get correctAnswer => correctAnswers.first;

  List<String> get incorrectAnswers =>
      options.where((option) => !correctAnswers.contains(option)).toList();

  List<String> get shuffledOptions => options;

  bool isCorrect(String answer) => correctAnswers.contains(answer);
}
