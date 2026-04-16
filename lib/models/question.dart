class Question {
  final String question;
  final List<Map<String, dynamic>> answers;

  Question({
    required this.question,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedAnswers = [];

    if (json['answers'] is List) {
      parsedAnswers = List<Map<String, dynamic>>.from(json['answers']);
    }

    return Question(
      question: json['text']?.toString() ??
          json['question']?.toString() ??
          'No question available',
      answers: parsedAnswers,
    );
  }

  List<Map<String, dynamic>> getValidAnswers() {
    return answers.where((a) => a['text'] != null).toList();
  }

  String getCorrectAnswerText() {
    for (final ans in answers) {
      if (ans['isCorrect'] == true) {
        return ans['text'];
      }
    }
    return "";
  }
}