import 'package:flutter/material.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
import 'wear_account_screen.dart';

class WearMenuScreen extends StatelessWidget {
  const WearMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);
    final isRound = isLikelyRoundWatch(context);

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
                icon: Icons.manage_accounts_outlined,
                label: 'Cuentas',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const WearAccountScreen()),
                ),
              ),
              // Agrega más _MenuItem aquí para futuras opciones
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  color: WearColors.textSecondary,
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
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Icon(icon, color: WearColors.headerTeal, size: 17),
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
    );
  }
}
