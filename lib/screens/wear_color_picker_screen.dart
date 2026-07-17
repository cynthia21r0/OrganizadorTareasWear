import 'package:flutter/material.dart';
import '../theme/wear_colors.dart';
import '../theme/wear_theme.dart';
import '../utils/screen_utils.dart';

class WearColorPickerScreen extends StatelessWidget {
  const WearColorPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WearTheme.of(context);
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
                'COLOR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WearColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              ...WearColors.palettes.map(
                (palette) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _PaletteTile(
                    palette: palette,
                    isSelected: controller.palette.id == palette.id,
                    onTap: () => controller.setPalette(palette),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: WearColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: WearColors.cardShadow,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.keyboard_arrow_up,
                          color: controller.palette.primary, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Volver',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: WearColors.textNavy),
                      ),
                    ],
                  ),
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

class _PaletteTile extends StatelessWidget {
  final WearPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary.withValues(alpha: 0.12)
              : WearColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: palette.primary, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
                color: WearColors.cardShadow,
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Muestra un degradado de la paleta
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.primary, palette.dark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                palette.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? palette.dark : WearColors.textNavy,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: palette.primary, size: 14),
          ],
        ),
      ),
    );
  }
}
