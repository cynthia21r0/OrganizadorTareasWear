import 'package:flutter/material.dart';

// Paletas disponibles: primary = color principal, dark = variante oscura
class WearPalette {
  final String id;
  final String label;
  final Color primary;
  final Color dark;

  const WearPalette({
    required this.id,
    required this.label,
    required this.primary,
    required this.dark,
  });
}

class WearColors {
  WearColors._();

  // Colores fijos (no cambian con el tema)
  static const Color background    = Color(0xFFF3F6F8);
  static const Color textNavy      = Color(0xFF10283F);
  static const Color textSecondary = Color(0xFF7E93A6);
  static const Color cardBackground = Colors.white;
  static const Color cardShadow    = Color(0x14000000);
  static const Color progressTrack = Color(0xFFE1EAEE);
  static const Color white         = Colors.white;

  // Color por defecto (usado antes de que el tema cargue)
  static const Color headerTeal     = Color(0xFF5FC6D8);
  static const Color headerTealDark = Color(0xFF4FB6C9);

  // Paletas disponibles
  static const List<WearPalette> palettes = [
    WearPalette(
      id: 'teal',
      label: 'Azul agua',
      primary: Color(0xFF5FC6D8),
      dark:    Color(0xFF4FB6C9),
    ),
    WearPalette(
      id: 'blue',
      label: 'Azul marino',
      primary: Color(0xFF4A90D9),
      dark:    Color(0xFF3A7FC8),
    ),
    WearPalette(
      id: 'indigo',
      label: 'Índigo',
      primary: Color(0xFF5C6BC0),
      dark:    Color(0xFF4A5AB0),
    ),
    WearPalette(
      id: 'purple',
      label: 'Violeta',
      primary: Color(0xFF8E6FD8),
      dark:    Color(0xFF7D5EC7),
    ),
    WearPalette(
      id: 'green',
      label: 'Verde',
      primary: Color(0xFF4CAF82),
      dark:    Color(0xFF3B9E71),
    ),
    WearPalette(
      id: 'orange',
      label: 'Naranja',
      primary: Color(0xFFE8834A),
      dark:    Color(0xFFD7723A),
    ),
  ];

  static WearPalette paletteById(String id) =>
      palettes.firstWhere((p) => p.id == id, orElse: () => palettes.first);
}
