import 'package:flutter/material.dart';
import 'screens/wear_splash_screen.dart';
import 'theme/wear_colors.dart';

void main() {
  runApp(const HomeTasksWearApp());
}

class HomeTasksWearApp extends StatelessWidget {
  const HomeTasksWearApp({super.key});

  @override
  Widget build(BuildContext context) {
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
