import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../weather/weather_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> categories = const [
    {
      'id': 'gen',
      'title': 'Culture générale',
      'icon': Icons.psychology,
      'count': 4603,
    },
    {
      'id': 'science',
      'title': 'Science',
      'icon': Icons.science,
      'count': 50,
    },
    {
      'id': 'myth',
      'title': 'Mythologie',
      'icon': Icons.account_balance,
      'count': 169,
    },
    {
      'id': 'sport',
      'title': 'Sport',
      'icon': Icons.sports_basketball,
      'count': 754,
    },
    {
      'id': 'geo',
      'title': 'Géographie',
      'icon': Icons.public,
      'count': 780,
    },
    {
      'id': 'his',
      'title': 'Histoire',
      'icon': Icons.menu_book,
      'count': 894,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catégories")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🌦️ MÉTÉO (API REST)
            const WeatherWidget(),
            const SizedBox(height: 16),
            // 📚 LISTE DES CATÉGORIES
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];

                  return GestureDetector(
                    onTap: () {
                      context.go(
                        AppRoutes.quiz,
                        extra: {
                          'categoryId': cat['id'],
                          'title': cat['title'],
                        },
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(cat['icon'], color: Theme.of(context).colorScheme.primary, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cat['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${cat['count']} questions",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // BOUTON CRÉER UN QUIZ
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.createQuiz),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Créer un quiz"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
