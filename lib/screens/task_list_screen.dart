import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../theme/wear_colors.dart';
import '../theme/wear_theme.dart';
import '../utils/screen_utils.dart';
import 'task_detail_screen.dart';
import 'wear_menu_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String userName;
  final String? profilePicture;
  final List<WearTask> initialTasks;

  const TaskListScreen({
    super.key,
    required this.userName,
    this.profilePicture,
    required this.initialTasks,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late List<WearTask> _tasks;
  WearThemeController? _themeController;

  @override
  void initState() {
    super.initState();
    _tasks = widget.initialTasks;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Suscribirse al controller del tema para reconstruir esta pantalla
    // inmediatamente cuando cambie la paleta (p.ej. al volver del selector).
    final controller = WearTheme.of(context);
    if (_themeController != controller) {
      _themeController?.removeListener(_onThemeChanged);
      _themeController = controller;
      _themeController!.addListener(_onThemeChanged);
    }
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _themeController?.removeListener(_onThemeChanged);
    super.dispose();
  }

  int get _completedCount =>
      _tasks.where((t) => t.status == WearTaskStatus.completada).length;

  void _handleTaskUpdated(WearTask updated) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) _tasks[index] = updated;
    });
  }

  void _openTask(WearTask task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          userName: widget.userName,
          avatarUrl: widget.profilePicture,
          onTaskUpdated: _handleTaskUpdated,
        ),
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
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, hPad, isRound)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 20),
              sliver: SliverList.separated(
                itemCount: _tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _TaskListItem(
                  task: _tasks[i],
                  onTap: () => _openTask(_tasks[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMenu() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WearMenuScreen()),
    );
  }

  Widget _buildHeader(BuildContext context, double hPad, bool isRound) {
    final primary = WearTheme.primary(context);
    final dark = WearTheme.dark(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(hPad, isRound ? 18 : 12, hPad, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, dark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'HOMETASKS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Tareas de ${widget.userName}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Botón de menú pill
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _openMenu,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.more_horiz, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'MENÚ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$_completedCount/${_tasks.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _tasks.isEmpty ? 0 : _completedCount / _tasks.length,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.35),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final WearTask task;
  final VoidCallback onTap;

  const _TaskListItem({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == WearTaskStatus.completada;
    final primary = WearTheme.primary(context);
    final dark = WearTheme.dark(context);
    return Material(
      color: WearColors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: WearColors.cardShadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(task.icon, color: dark, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: WearColors.textNavy,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.timeLabel,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: WearColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: WearColors.textSecondary.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
