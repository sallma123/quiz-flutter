import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../providers/history_provider.dart';
import '../../models/history_record.dart';

enum SortType { date, score }
enum SortOrder { asc, desc }

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String? selectedCategory;
  SortType sortType = SortType.date;
  SortOrder sortOrder = SortOrder.desc;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<HistoryRecord>('history');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text("Historique"),
        centerTitle: true,
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<HistoryRecord> box, _) {
          final history = box.values.toList().reversed.toList();

          if (history.isEmpty) {
            return const Center(
              child: Text(
                "Aucun quiz pour le moment",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final h = history[index];
              final percent =
              ((h.score / (h.totalQuestions * 10)) * 100).round();

              Color badgeColor = percent >= 70
                  ? Colors.green
                  : percent >= 40
                  ? Colors.orange
                  : Colors.red;

              return GestureDetector(
                onTap: () {
                  context.push(
                    '/answers',
                    extra: {
                      'questions': h.questions,
                      'selections': h.selections,
                    },
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "$percent%",
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${h.score} / ${h.totalQuestions * 10} pts",
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${h.dateTime.day}/${h.dateTime.month}/${h.dateTime.year}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

}
