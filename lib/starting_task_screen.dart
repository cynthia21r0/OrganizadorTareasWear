import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../theme/wear_colors.dart';
import 'completed_screen.dart';

class StartingTaskScreen extends StatefulWidget {
  final WearTask task;
  final ValueChanged<WearTask> onTaskUpdated;

  const StartingTaskScreen({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<StartingTaskScreen> createState() => _StartingTaskScreenState();
}

class _StartingTaskScreenState extends State<StartingTaskScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompletedScreen(
            task: widget.task,
            onTaskUpdated: widget.onTaskUpdated,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WearColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: WearColors.headerTeal,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'INICIANDO TAREA...',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: WearColors.textNavy,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.task.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: WearColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Puedes cerrar y retomar después',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: WearColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
