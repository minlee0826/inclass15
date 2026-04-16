import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/trivia_service.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TriviaService service = TriviaService();

  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;
  String? errorMessage;

  String? selectedAnswerText;
  String correctAnswerText = "";
  List<Map<String, dynamic>> options = [];

  String explanation = "";
  bool isExplaining = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await service.fetchQuestions();

      setState(() {
        questions = data;
        currentIndex = 0;
        score = 0;
        isLoading = false;
        setupQuestion();
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void setupQuestion() {
    if (questions.isEmpty) return;

    final q = questions[currentIndex];
    options = q.getValidAnswers();
    options.shuffle();
    correctAnswerText = q.getCorrectAnswerText();
    selectedAnswerText = null;
    explanation = "";
    isExplaining = false;
  }

  Future<void> generateExplanation(String question, String correctAnswer) async {
    setState(() {
      isExplaining = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    explanation =
        'AI Hint: The correct answer is "$correctAnswer" because it best matches the concept being tested in this question. Review the wording carefully and connect it to the main programming idea in the question.';

    setState(() {
      isExplaining = false;
    });
  }

  void selectAnswer(Map<String, dynamic> answer) {
    if (selectedAnswerText != null) return;

    final chosenText = answer['text']?.toString() ?? '';

    setState(() {
      selectedAnswerText = chosenText;

      if (answer['isCorrect'] == true) {
        score++;
      }
    });

    generateExplanation(
      questions[currentIndex].question,
      correctAnswerText,
    );
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        setupQuestion();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            score: score,
            total: questions.length,
            restart: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const QuizScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  Color getColor(Map<String, dynamic> answer) {
    if (selectedAnswerText == null) return Colors.white;

    final answerText = answer['text']?.toString() ?? '';
    final isCorrect = answer['isCorrect'] == true;

    if (isCorrect) return Colors.green.shade200;
    if (answerText == selectedAnswerText && !isCorrect) {
      return Colors.red.shade200;
    }

    return Colors.white;
  }

  IconData getIcon(Map<String, dynamic> answer) {
    if (selectedAnswerText == null) return Icons.help_outline;

    final answerText = answer['text']?.toString() ?? '';
    final isCorrect = answer['isCorrect'] == true;

    if (isCorrect) return Icons.check_circle;
    if (answerText == selectedAnswerText && !isCorrect) {
      return Icons.cancel;
    }

    return Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz App")),
        body: Center(
          child: Image.asset(
            'assets/images/loading.png',
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return const CircularProgressIndicator();
            },
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz App")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loadQuestions,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz App")),
        body: const Center(
          child: Text("No questions found"),
        ),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz App")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              q.question,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) {
              final answerText = opt['text']?.toString() ?? '';

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor(opt),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: selectedAnswerText == null
                      ? () => selectAnswer(opt)
                      : null,
                  icon: Icon(getIcon(opt)),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      answerText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            if (selectedAnswerText != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isExplaining
                      ? const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Generating explanation..."),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "AI Explanation",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              explanation,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
            const SizedBox(height: 20),
            if (selectedAnswerText != null)
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text(
                  currentIndex == questions.length - 1 ? "See Result" : "Next",
                ),
              ),
          ],
        ),
      ),
    );
  }
}