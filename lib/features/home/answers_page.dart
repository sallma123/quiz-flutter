import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/question.dart';

class AnswersPage extends StatelessWidget {
  final List<Question> questions;
  final List<int?> selections;

  const AnswersPage({
    super.key,
    required this.questions,
    required this.selections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),

      // =====================
      // APP BAR MODERNE
      // =====================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Vos réponses",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // =====================
      // LISTE DES QUESTIONS
      // =====================
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          final selected = selections[index];
          final correctIndex = q.correctIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================
                // QUESTION HEADER
                // =====================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9C77FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =====================
                // OPTIONS
                // =====================
                ...List.generate(q.options.length, (i) {
                  final bool isCorrect = i == correctIndex;
                  final bool isSelected = selected == i;

                  Color bgColor = Colors.grey.shade100;
                  Color borderColor = Colors.transparent;
                  IconData? icon;

                  if (isCorrect) {
                    bgColor = Colors.green.shade50;
                    borderColor = Colors.green;
                    icon = Icons.check_circle;
                  } else if (isSelected && !isCorrect) {
                    bgColor = Colors.red.shade50;
                    borderColor = Colors.red;
                    icon = Icons.cancel;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.options[i],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        if (icon != null)
                          Icon(
                            icon,
                            color:
                            isCorrect ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
