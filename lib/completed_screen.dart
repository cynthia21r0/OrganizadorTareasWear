import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../services/wear_task_repository.dart';
import '../theme/wear_colors.dart';

class CompletedScreen extends StatefulWidget {
  final WearTask task;
  final ValueChanged<WearTask> onTaskUpdated;

  const CompletedScreen({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  final _repository = WearTaskRepository();
  bool _syncing = false;

  Future<void> _finishAndReturn() async {
    setState(() => _syncing = true);
    final updated = widget.task.copyWith(status: WearTaskStatus.completada);

    try {
      await _repository.toggleStatus(updated.id);
    } catch (_) {}

    widget.onTaskUpdated(updated);

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WearColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: WearColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 14),
              const Text(
                '¡COMPLETADA!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: WearColors.textNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.task.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: WearColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _syncing ? null : _finishAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WearColors.headerTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _syncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'VER TODAS LAS TAREAS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
