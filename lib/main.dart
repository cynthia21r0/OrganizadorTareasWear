import 'package:flutter/material.dart';
import 'screens/wear_splash_screen.dart';
import 'theme/wear_colors.dart';
import 'theme/wear_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar paleta guardada antes de mostrar cualquier UI
  final controller = WearThemeController();
  await controller.load();

  runApp(HomeTasksWearApp(themeController: controller));
}

class HomeTasksWearApp extends StatelessWidget {
  final WearThemeController themeController;
  const HomeTasksWearApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return WearThemeProvider(
      controller: themeController,
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    // ThemeData es estático: las pantallas leen el color dinámico directamente
    // a través de WearTheme.of(context), evitando reconstruir MaterialApp
    // en cada cambio de paleta (lo que causaba el retraso visible).
    return MaterialApp(
      title: 'HomeTasks Wear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: WearColors.background,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: WearColors.headerTeal,
          primary: WearColors.headerTeal,
        ),
      ),
      home: const WearSplashScreen(),
    );
  }
}
