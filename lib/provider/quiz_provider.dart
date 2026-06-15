import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/question_model.dart';
import '../services/trevia_api_service.dart';
import 'quiz_state.dart';

final triviaApiProvider = Provider((ref) => TriviaApiService());

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(ref.read(triviaApiProvider)),
);

class QuizNotifier extends StateNotifier<QuizState> {
  final TriviaApiService apiService;

  QuizNotifier(this.apiService) : super(QuizState.initial());

  Future<void> startQuiz(String difficulty) async {
    state = state.copyWith(
      isLoading: true,
      questions: [],
      currentIndex: 0,
      score: 0,
      lives: 3,
      isFinished: false,
      mode: difficulty,
      clearError: true,
    );

    try {
      final questions = await apiService.getQuestions(difficulty);

      state = state.copyWith(questions: questions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load quiz questions. Check your connection and try again.',
      );
    }
  }

  void startCustomQuiz(List<QuestionModel> questions) {
    final shuffled = [...questions]..shuffle();

    state = state.copyWith(
      questions: shuffled,
      currentIndex: 0,
      score: 0,
      lives: 3,
      isLoading: false,
      isFinished: false,
      mode: 'custom',
      clearError: true,
    );
  }

  QuestionModel get currentQuestion => state.questions[state.currentIndex];

  void answerQuestion(String selectedAnswer) {
    if (currentQuestion.isCorrect(selectedAnswer)) {
      state = state.copyWith(score: state.score + 10);
    } else {
      state = state.copyWith(lives: state.lives > 0 ? state.lives - 1 : 0);
    }

    _moveToNextQuestion();
  }

  void skipQuestion() {
    state = state.copyWith(score: state.score - 5);

    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (state.lives <= 0) {
      finishQuiz();
      return;
    }

    if (state.currentIndex >= state.questions.length - 1) {
      finishQuiz();
      return;
    }

    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void finishQuiz() {
    state = state.copyWith(isFinished: true);
  }

  void resetQuiz() {
    state = QuizState.initial();
  }
}
