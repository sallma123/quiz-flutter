import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import '../profile/profile_page.dart';

/// Page principale de navigation
/// Contient la barre de navigation inférieure et les pages principales
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {

  // Index de l’onglet actuellement sélectionné
  int _index = 0;

  // Liste des pages affichées selon l’onglet actif
  final _screens = const [
    HomePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(

      // Affiche la page correspondant à l’onglet sélectionné
      body: _screens[_index],

      // Barre de navigation inférieure personnalisée
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [

              // Indicateur animé de l’onglet actif
              AnimatedAlign(
                alignment: Alignment(
                  _index == 0 ? -1 : _index == 1 ? 0 : 1,
                  0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width / 3,
                  color: colors.primary,
                ),
              ),

              // Ligne contenant les boutons de navigation
              Expanded(
                child: Row(
                  children: [

                    // Onglet Accueil
                    _NavItem(
                      icon: Icons.home,
                      label: "Accueil",
                      isActive: _index == 0,
                      onTap: () => setState(() => _index = 0),
                      colors: colors,
                    ),

                    // Onglet Historique
                    _NavItem(
                      icon: Icons.history,
                      label: "Historique",
                      isActive: _index == 1,
                      onTap: () => setState(() => _index = 1),
                      colors: colors,
                    ),

                    // Onglet Profil
                    _NavItem(
                      icon: Icons.person,
                      label: "Profil",
                      isActive: _index == 2,
                      onTap: () => setState(() => _index = 2),
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Élément individuel de la barre de navigation
/// Représente un onglet (icône + texte)
class _NavItem extends StatelessWidget {

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Icône de l’onglet
            Icon(
              icon,
              color: isActive
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.45),
            ),

            const SizedBox(height: 4),

            // Texte de l’onglet
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
