import 'package:flutter/material.dart';
import '../theme/wear_colors.dart';
import '../theme/wear_theme.dart';
import '../utils/screen_utils.dart';
import 'wear_account_screen.dart';
import 'wear_add_task_screen.dart';
import 'wear_color_picker_screen.dart';
import 'wear_edit_profile_screen.dart';

class WearMenuScreen extends StatelessWidget {
  const WearMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);
    final isRound = isLikelyRoundWatch(context);
    final primary = WearTheme.primary(context);

    return Scaffold(
      backgroundColor: WearColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: isRound ? 20 : 12),
              const Text(
                'MENÚ',
                style: TextStyle(
                  color: WearColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _MenuItem(
                icon: Icons.add_task,
                label: 'Nueva tarea',
                primary: primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const WearAddTaskScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Mi perfil',
                primary: primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const WearEditProfileScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.palette_outlined,
                label: 'Color',
                primary: primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const WearColorPickerScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.manage_accounts_outlined,
                label: 'Cuentas',
                primary: primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const WearAccountScreen()),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: primary,
                  size: 20,
                ),
              ),
              SizedBox(height: isRound ? 20 : 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: WearColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: WearColors.cardShadow,
                  blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: primary, size: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WearColors.textNavy,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: WearColors.textSecondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
