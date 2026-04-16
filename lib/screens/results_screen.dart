import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback restart;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.total,
    required this.restart,
  });

  String getFeedback() {
    final percentage = score / total;

    if (percentage >= 0.8) {
      return "Excellent! You have strong knowledge and performed very well in this quiz.";
    } else if (percentage >= 0.5) {
      return "Good job! You understand many concepts, but a little more practice will help you improve.";
    } else {
      return "Keep learning! Review the explanations, practice more questions, and try again to improve your score.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentText = ((score / total) * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/trophy.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: Colors.amber,
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Score: $score / $total",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                "Percentage: $percentText%",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    getFeedback(),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: restart,
                child: const Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}