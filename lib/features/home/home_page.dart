import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../weather/weather_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';

  static const List<Map<String, dynamic>> categories = [
    {'id': 'gen', 'title': 'Culture générale', 'icon': Icons.psychology},
    {'id': 'science', 'title': 'Science', 'icon': Icons.science},
    {'id': 'myth', 'title': 'Mythologie', 'icon': Icons.account_balance},
    {'id': 'sport', 'title': 'Sport', 'icon': Icons.sports_basketball},
    {'id': 'geo', 'title': 'Géographie', 'icon': Icons.public},
    {'id': 'his', 'title': 'Histoire', 'icon': Icons.menu_book},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // ✅ RÉCUPÉRATION UTILISATEUR
    final userBox = Hive.box<User>('users');
    final String userName =
    userBox.isNotEmpty ? userBox.values.first.name : 'Utilisateur';

    final filtered = categories
        .where((c) =>
        c['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: colors.background,

      // ✅ HEADER MODERNE
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 BONJOUR + NOM
                Text(
                  "Bonjour $userName 👋",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Testez vos connaissances",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔍 SEARCH
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: "Rechercher un quiz",
                    prefixIcon: Icon(
                      Icons.search,
                      color: colors.secondary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 4,
            width: 60,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // 🌦️ MÉTÉO DISCRÈTE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: WeatherWidget(),
          ),

          const SizedBox(height: 12),

          // 📚 LISTE MODERNE
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cat = filtered[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.go(
                      AppRoutes.quiz,
                      extra: {
                        'categoryId': cat['id'],
                        'title': cat['title'],
                      },
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        // ICON
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withOpacity(0.12),
                          ),
                          child: Icon(
                            cat['icon'],
                            color: colors.primary,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // TITLE
                        Expanded(
                          child: Text(
                            cat['title'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: colors.secondary.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),


      // ➕ FAB discret
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createQuiz),
        backgroundColor: colors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
