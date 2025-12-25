import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/history_record.dart';

/// Page Historique
/// Affiche la liste des quiz déjà passés par l'utilisateur
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  // Catégorie sélectionnée pour le filtre (null = toutes)
  String? selectedCategory;

  /// Formate la date et l'heure d'un quiz
  String formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)} • ${two(d.hour)}:${two(d.minute)}";
  }

  @override
  Widget build(BuildContext context) {

    // Récupération du thème et des couleurs
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Box Hive contenant l'historique
    final box = Hive.box<HistoryRecord>('history');

    return Scaffold(
      backgroundColor: colors.background,

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),

        // Reconstruit l'UI automatiquement quand l'historique change
        builder: (context, Box<HistoryRecord> box, _) {

          // Liste complète des quiz (du plus récent au plus ancien)
          final allHistory = box.values.toList().reversed.toList();

          // Liste des catégories disponibles
          final categories = {
            for (var h in box.values) h.categoryId: h.title
          };

          // Application du filtre par catégorie
          final history = selectedCategory == null
              ? allHistory
              : allHistory
              .where((h) => h.categoryId == selectedCategory)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 48),

              // Titre principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Votre progression",
                  style: theme.textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 6),

              // Sous-titre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Retrouvez vos derniers quiz",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Conteneur principal (zone colorée)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [

                      const SizedBox(height: 16),

                      // Liste horizontale des filtres par catégorie
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                          children: [

                            // Filtre "Tous"
                            _FilterChip(
                              label: "Tous",
                              active: selectedCategory == null,
                              inverted: true,
                              onTap: () =>
                                  setState(() => selectedCategory = null),
                            ),

                            // Filtres par catégorie
                            ...categories.entries.map(
                                  (e) => _FilterChip(
                                label: e.value,
                                active: selectedCategory == e.key,
                                inverted: true,
                                onTap: () => setState(
                                      () => selectedCategory = e.key,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Liste des quiz joués
                      Expanded(
                        child: history.isEmpty
                            ? Center(
                          child: Text(
                            "Aucun quiz pour cette catégorie",
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 24),
                          itemCount: history.length,
                          itemBuilder: (context, index) {

                            final h = history[index];

                            // Calcul du pourcentage de réussite
                            final percent =
                            ((h.score /
                                (h.totalQuestions * 10)) *
                                100)
                                .round();

                            // Couleur du score selon la performance
                            final Color scoreColor =
                            percent >= 80
                                ? colors.primary
                                : percent >= 40
                                ? colors.secondary
                                : Colors.grey;

                            return InkWell(
                              borderRadius:
                              BorderRadius.circular(16),

                              // Navigation vers la page des réponses
                              onTap: () {
                                context.push(
                                  '/answers',
                                  extra: {
                                    'questions': h.questions,
                                    'selections': h.selections,
                                  },
                                );
                              },

                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [

                                    // Cercle affichant le score
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: scoreColor.withValues(
                                            alpha: 0.12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$percent%",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: scoreColor,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Informations du quiz
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h.title,
                                            style: theme
                                                .textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${h.score} / ${h.totalQuestions * 10} pts",
                                            style: theme
                                                .textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formatDate(h.dateTime),
                                            style: theme
                                                .textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Icône de navigation
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: colors.secondary,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget de filtre personnalisé
/// Utilisé pour sélectionner une catégorie
class _FilterChip extends StatelessWidget {

  final String label;
  final bool active;
  final bool inverted;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    this.active = false,
    this.inverted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    final bg = active
        ? colors.secondary
        : (inverted
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white);

    final border = inverted
        ? Colors.white.withValues(alpha: 0.4)
        : colors.secondary.withValues(alpha: 0.4);

    final textColor =
    active ? Colors.white : (inverted ? Colors.white : colors.onBackground);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
