import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class TriviaService {
  static const String _apiKey = String.fromEnvironment('QUIZ_API_KEY');

  Future<List<Question>> fetchQuestions() async {
    if (_apiKey.isEmpty) {
      throw Exception(
        "Missing API key. Run with --dart-define=QUIZ_API_KEY=YOUR_API_KEY",
      );
    }

    final url = Uri.parse(
      "https://quizapi.io/api/v1/questions?limit=10&category=Programming&difficulty=EASY&type=MULTIPLE_CHOICE",
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load questions: ${response.statusCode}");
    }

    final decoded = json.decode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Unexpected API response format");
    }

    if (decoded['success'] != true) {
      throw Exception("API returned success = false");
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception("API data is not a list");
    }

    final questions = data
        .whereType<Map>()
        .map((item) => Question.fromJson(Map<String, dynamic>.from(item)))
        .where((q) => q.question.trim().isNotEmpty && q.answers.isNotEmpty)
        .toList();

    if (questions.isEmpty) {
      throw Exception("No valid questions found from API");
    }

    return questions;
  }
}
