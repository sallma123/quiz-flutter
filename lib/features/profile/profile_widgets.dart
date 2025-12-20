import 'package:flutter/material.dart';
import '../../models/user.dart';

/// =====================
/// PROFILE HEADER
/// =====================
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 28),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style:
            theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            children: [
              ProfileHeaderAction(
                icon: Icons.edit,
                label: "Profil",
                onTap: onEditProfile,
              ),
              ProfileHeaderAction(
                icon: Icons.lock,
                label: "Mot de passe",
                onTap: onChangePassword,
              ),
              ProfileHeaderAction(
                icon: Icons.logout,
                label: "Quitter",
                onTap: onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =====================
/// HEADER ACTION BUTTON
/// =====================
class ProfileHeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileHeaderAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// STAT CARD
/// =====================
class ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.secondary),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// SECTION CARD
/// =====================
class ProfileSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class AnimatedBadge extends StatefulWidget {
  final IconData icon;
  final bool active;
  final String label;
  final String description;

  const AnimatedBadge({
    super.key,
    required this.icon,
    required this.active,
    required this.label,
    required this.description,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // ✅ Toujours visible
    _controller.value = 1.0;

    // ✨ Petite animation seulement si actif
    if (widget.active) {
      _controller.forward(from: 0.85);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showExplanation(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      useSafeArea: true, // ✅ Flutter 3.10+
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        top: false, // ❌ on garde le haut arrondi
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 48, color: colors.primary),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final badgeColor = widget.active
        ? colors.primary
        : colors.onSurface.withValues(alpha: 0.35);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onLongPress: () => _showExplanation(context),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: badgeColor.withValues(alpha: 0.15),
              child: Icon(widget.icon, color: badgeColor),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}


/// =====================
/// INSIGHT CARD
/// =====================
class ProfileInsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const ProfileInsightCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


