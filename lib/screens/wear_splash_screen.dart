import 'package:flutter/material.dart';
import '../services/wear_api_client.dart';
import '../services/wear_auth_repository.dart';
import '../services/wear_task_repository.dart';
import '../services/notification_service.dart';
import '../services/auth_storage.dart';
import '../models/wear_task.dart';
import '../theme/wear_colors.dart';
import 'task_list_screen.dart';

class WearSplashScreen extends StatefulWidget {
  const WearSplashScreen({super.key});

  @override
  State<WearSplashScreen> createState() => _WearSplashScreenState();
}

class _WearSplashScreenState extends State<WearSplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirstUser();
  }

  Future<void> _loadFirstUser() async {
    try {
      await NotificationService().init();

      // Intentar recuperar sesión guardada
      final saved = await AuthStorage.loadActive();
      String token, userId, userName;
      String? profilePicture;

      if (saved != null) {
        token = saved.token;
        userId = saved.userId;
        userName = saved.userName;
        profilePicture = saved.profilePicture;
        WearApiClient.instance.token = token;
        WearApiClient.instance.userId = userId;
      } else {
        final result = await WearAuthRepository().getFirstUser();
        token = result.token;
        userId = result.userId;
        userName = result.userName;
        profilePicture = result.profilePicture;
        WearApiClient.instance.token = token;
        WearApiClient.instance.userId = userId;
        await AuthStorage.saveAccount(SavedAccount(
          token: token,
          userId: userId,
          userName: userName,
          profilePicture: profilePicture,
        ));
      }

      final tasks = await WearTaskRepository().getMyTasks(userId);

      final pendingTasksCount = tasks
          .where((t) => t.status == WearTaskStatus.pendiente)
          .length;
      if (pendingTasksCount > 0) {
        await NotificationService().showPendingTasksNotification(
          pendingTasksCount,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TaskListScreen(
            userName: userName.isNotEmpty ? userName : 'Usuario',
            profilePicture: profilePicture,
            initialTasks: tasks,
          ),
        ),
      );
    } catch (e) {
      // Si el token guardado ya no es válido, limpiar y reintentar con login
      await AuthStorage.clearAll();
      if (mounted) {
        setState(() => _error = 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WearColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WearColors.headerTeal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'HomeTasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: WearColors.textNavy,
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _loadFirstUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WearColors.headerTeal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'REINTENTAR',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: WearColors.headerTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cargando...',
                  style: TextStyle(fontSize: 12, color: WearColors.headerTeal),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
