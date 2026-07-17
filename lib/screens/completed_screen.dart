import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../services/wear_task_repository.dart';
import '../theme/wear_colors.dart';
import '../theme/wear_theme.dart';
import '../utils/screen_utils.dart';

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
    final hPad = safeHorizontalPadding(context);
    final primary = WearTheme.primary(context);
    return Scaffold(
      backgroundColor: WearColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 12),
                const Text(
                  '¡COMPLETADA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: WearColors.textNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.task.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: WearColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _syncing ? null : _finishAndReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _syncing
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'VER TODAS LAS TAREAS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
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
