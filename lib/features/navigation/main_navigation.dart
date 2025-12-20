import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import '../profile/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = 0;

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
      body: _screens[_index],

      // =====================
      // NAVIGATION MODERNE
      // =====================
      bottomNavigationBar: SafeArea(
        top: false, // on ignore le haut
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
              // INDICATEUR
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

              // ITEMS
              Expanded(
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      label: "Accueil",
                      isActive: _index == 0,
                      onTap: () => setState(() => _index = 0),
                      colors: colors,
                    ),
                    _NavItem(
                      icon: Icons.history,
                      label: "Historique",
                      isActive: _index == 1,
                      onTap: () => setState(() => _index = 1),
                      colors: colors,
                    ),
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

/// =====================
/// ITEM NAVIGATION
/// =====================
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
            Icon(
              icon,
              color: isActive
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
