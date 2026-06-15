import '../models/question_model.dart';

class QuizState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final int score;
  final int lives;
  final bool isLoading;
  final bool isFinished;
  final String? errorMessage;
  final String mode;

  const QuizState({
    required this.questions,
    required this.currentIndex,
    required this.score,
    required this.lives,
    required this.isLoading,
    required this.isFinished,
    required this.errorMessage,
    required this.mode,
  });

  factory QuizState.initial() {
    return const QuizState(
      questions: [],
      currentIndex: 0,
      score: 0,
      lives: 3,
      isLoading: false,
      isFinished: false,
      errorMessage: null,
      mode: 'api',
    );
  }

  QuizState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    int? score,
    int? lives,
    bool? isLoading,
    bool? isFinished,
    String? errorMessage,
    String? mode,
    bool clearError = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
    );
  }
}
