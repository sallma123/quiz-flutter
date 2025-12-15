import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/history_record.dart';

enum SortType { date, score }
enum SortOrder { asc, desc }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? selectedCategory; // null = toutes
  SortType sortType = SortType.date;
  SortOrder sortOrder = SortOrder.desc;

  // =====================
  // FORMAT DATE
  // =====================
  String formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');

    final day = two(d.day);
    final month = two(d.month);
    final year = d.year.toString().substring(2);
    final hour = two(d.hour);
    final minute = two(d.minute);

    return "$day/$month/$year | $hour:$minute";
  }

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
          List<HistoryRecord> history =
          box.values.toList().reversed.toList();

          // --------------------
          // FILTRAGE CATÉGORIE
          // --------------------
          if (selectedCategory != null) {
            history = history
                .where((h) => h.categoryId == selectedCategory)
                .toList();
          }

          // --------------------
          // TRI
          // --------------------
          history.sort((a, b) {
            int cmp;
            if (sortType == SortType.date) {
              cmp = a.dateTime.compareTo(b.dateTime);
            } else {
              cmp = a.score.compareTo(b.score);
            }
            return sortOrder == SortOrder.asc ? cmp : -cmp;
          });

          // Catégories uniques
          final categories = {
            for (var h in box.values) h.categoryId: h.title
          };

          return Column(
            children: [
              // =====================
              // FILTRES MODERNES
              // =====================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // ---- Catégorie (avec "Toutes")
                    DropdownButton<String?>(
                      value: selectedCategory,
                      hint: const Text("Catégorie"),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("Toutes les catégories"),
                        ),
                        ...categories.entries.map(
                              (e) => DropdownMenuItem<String?>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => selectedCategory = v);
                      },
                    ),

                    const Spacer(),

                    // ---- Tri
                    DropdownButton<SortType>(
                      value: sortType,
                      items: const [
                        DropdownMenuItem(
                          value: SortType.date,
                          child: Text("Date"),
                        ),
                        DropdownMenuItem(
                          value: SortType.score,
                          child: Text("Score"),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => sortType = v!),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      icon: Icon(
                        sortOrder == SortOrder.desc
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                      onPressed: () {
                        setState(() {
                          sortOrder = sortOrder == SortOrder.desc
                              ? SortOrder.asc
                              : SortOrder.desc;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // =====================
              // LISTE HISTORIQUE
              // =====================
              Expanded(
                child: history.isEmpty
                    ? const Center(
                  child: Text(
                    "Aucun quiz pour le moment",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final h = history[index];
                    final percent =
                    ((h.score / (h.totalQuestions * 10)) * 100)
                        .round();

                    final badgeColor = percent >= 70
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
                              // Badge %
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

                              // Infos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                      formatDate(h.dateTime),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
