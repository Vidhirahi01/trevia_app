import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/question_model.dart';

final customQuizProvider =
    StateNotifierProvider<CustomQuizNotifier, List<QuestionModel>>(
      (ref) => CustomQuizNotifier(),
    );

class CustomQuizNotifier extends StateNotifier<List<QuestionModel>> {
  CustomQuizNotifier() : super([]);

  void addQuestion(QuestionModel question) {
    if (state.length >= 10) return;

    state = [...state, question];
  }

  void deleteQuestion(String id) {
    state = state.where((q) => q.id != id).toList();
  }

  void updateQuestion(QuestionModel updated) {
    state = state.map((question) {
      if (question.id == updated.id) {
        return updated;
      }

      return question;
    }).toList();
  }
}
