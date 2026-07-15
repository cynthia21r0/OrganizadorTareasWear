import 'package:flutter/material.dart';
import '../models/wear_task.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
import 'task_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _tasks = widget.initialTasks;
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

  Widget _buildHeader(BuildContext context, double hPad, bool isRound) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(hPad, isRound ? 18 : 12, hPad, 14),
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
          const SizedBox(height: 12),
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
              backgroundColor: Colors.white.withOpacity(0.35),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: WearColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: WearColors.cardShadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: WearColors.headerTeal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                task.icon,
                color: WearColors.headerTealDark,
                size: 17,
              ),
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
              color: WearColors.textSecondary.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
