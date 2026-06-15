import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question_model.dart';

class TriviaApiService {
  Future<List<QuestionModel>> getQuestions(String difficulty) async {
    final uri = Uri.https('the-trivia-api.com', '/api/questions', {
      'limit': '10',
      'difficulty': difficulty,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch questions");
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => QuestionModel.fromJson(e)).toList();
  }
}
