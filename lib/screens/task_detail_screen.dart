import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
import 'starting_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final WearTask task;
  final String userName;
  final String? avatarUrl;
  final ValueChanged<WearTask> onTaskUpdated;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.userName,
    required this.onTaskUpdated,
    this.avatarUrl,
  });

  void _markCompletedDirectly(BuildContext context) {
    onTaskUpdated(task.copyWith(status: WearTaskStatus.completada));
    Navigator.of(context).pop();
  }

  void _startTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            StartingTaskScreen(task: task, onTaskUpdated: onTaskUpdated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);
    final isRound = isLikelyRoundWatch(context);

    return Scaffold(
      backgroundColor: WearColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(hPad, isRound ? 16 : 12, hPad, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [WearColors.headerTeal, WearColors.headerTealDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TAREA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: WearColors.headerTeal.withOpacity(0.15),
                      backgroundImage: _getAvatarImage(avatarUrl),
                      child: avatarUrl == null
                          ? Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: WearColors.headerTealDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Icon(task.icon, color: WearColors.headerTealDark, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      task.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: WearColors.textNavy,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.timeLabel,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: WearColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (task.status != WearTaskStatus.completada) ...[
                      _PillButton(
                        label: 'MARCAR COMPLETADA',
                        filled: true,
                        onTap: () => _markCompletedDirectly(context),
                      ),
                      const SizedBox(height: 8),
                      _PillButton(
                        label: 'COMENZAR',
                        filled: false,
                        onTap: () => _startTask(context),
                      ),
                      const SizedBox(height: 8),
                    ],
                    _PillButton(
                      label: '← VOLVER',
                      filled: false,
                      bare: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(height: isRound ? 10 : 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? urlOrBase64) {
    if (urlOrBase64 == null || urlOrBase64.isEmpty) return null;

    try {
      if (urlOrBase64.startsWith('http')) {
        return NetworkImage(urlOrBase64);
      } else {
        final cleanBase64 = urlOrBase64.contains(',')
            ? urlOrBase64.split(',').last
            : urlOrBase64;
        return MemoryImage(base64Decode(cleanBase64));
      }
    } catch (e) {
      debugPrint('Error decodificando imagen de perfil: $e');
      return null;
    }
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool bare;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.bare = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? WearColors.headerTeal : Colors.white,
          foregroundColor: filled ? Colors.white : WearColors.headerTealDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: bare
                ? BorderSide.none
                : BorderSide(
                    color: filled ? Colors.transparent : WearColors.headerTeal,
                    width: 1.3,
                  ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: bare ? WearColors.textSecondary : null,
          ),
        ),
      ),
    );
  }
}
