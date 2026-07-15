import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
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
    final hPad = safeHorizontalPadding(context);
    return Scaffold(
      backgroundColor: WearColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: WearColors.headerTeal,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'INICIANDO TAREA...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: WearColors.textNavy,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.task.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: WearColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Puedes cerrar y retomar después',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: WearColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
