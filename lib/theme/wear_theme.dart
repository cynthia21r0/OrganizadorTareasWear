import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wear_colors.dart';

const _kPaletteKey = 'wear_palette_id';

// ── Controller ────────────────────────────────────────────────────────────────

class WearThemeController extends ChangeNotifier {
  WearPalette _palette = WearColors.palettes.first;

  WearPalette get palette => _palette;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kPaletteKey);
    if (id != null) _palette = WearColors.paletteById(id);
    notifyListeners();
  }

  Future<void> setPalette(WearPalette palette) async {
    _palette = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaletteKey, palette.id);
  }
}

// ── InheritedWidget ───────────────────────────────────────────────────────────

class WearTheme extends InheritedWidget {
  final WearThemeController controller;

  const WearTheme({
    super.key,
    required this.controller,
    required super.child,
  });

  static WearThemeController of(BuildContext context) {
    final wt = context.dependOnInheritedWidgetOfExactType<WearTheme>();
    assert(wt != null, 'WearTheme not found in context');
    return wt!.controller;
  }

  // Acceso rápido al color primario
  static Color primary(BuildContext context) => of(context).palette.primary;
  static Color dark(BuildContext context) => of(context).palette.dark;

  @override
  bool updateShouldNotify(WearTheme oldWidget) =>
      controller.palette != oldWidget.controller.palette;
}

// ── Provider widget ───────────────────────────────────────────────────────────

class WearThemeProvider extends StatefulWidget {
  final Widget child;
  final WearThemeController controller;
  const WearThemeProvider({super.key, required this.controller, required this.child});

  @override
  State<WearThemeProvider> createState() => _WearThemeProviderState();
}

class _WearThemeProviderState extends State<WearThemeProvider> {
  void _onThemeChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WearTheme(
      controller: widget.controller,
      child: widget.child,
    );
  }
}
