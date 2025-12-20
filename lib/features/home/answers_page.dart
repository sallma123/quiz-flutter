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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,

      // =====================
      // APP BAR (THEME)
      // =====================
      appBar: AppBar(
        title: const Text("Vos réponses"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
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
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                      decoration: BoxDecoration(
                        color: colors.primary,
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
                        style: theme.textTheme.bodyLarge?.copyWith(
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

                  // ⚠️ NE PAS TOUCHER AU VERT / ROUGE
                  Color bgColor = colors.background;
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
                      horizontal: 12,
                      vertical: 12,
                    ),
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
                            color: colors.surface,
                            border: Border.all(
                              color: borderColor == Colors.transparent
                                  ? colors.onSurface.withValues(alpha: 0.2)
                                  : borderColor,
                            ),
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
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (icon != null)
                          Icon(
                            icon,
                            color: isCorrect
                                ? Colors.green
                                : Colors.red,
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
