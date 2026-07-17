import 'package:flutter/material.dart';
import '../services/wear_api_client.dart';
import '../services/wear_auth_repository.dart';
import '../services/wear_task_repository.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
import 'task_list_screen.dart';

class WearAddTaskScreen extends StatefulWidget {
  const WearAddTaskScreen({super.key});

  @override
  State<WearAddTaskScreen> createState() => _WearAddTaskScreenState();
}

class _WearAddTaskScreenState extends State<WearAddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  static const _priorities = ['baja', 'media', 'alta'];
  String _priority = 'media';

  DateTime _dueDate = DateTime.now().add(const Duration(hours: 1));

  List<WearFamilyMember> _members = [];
  String? _assignedToId;
  bool _loadingMembers = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  bool get _isGuardian {
    final role = WearApiClient.instance.userRole ?? 'otro';
    return role == 'padre' || role == 'madre';
  }

  Future<void> _loadMembers() async {
    try {
      final members = await WearAuthRepository().getFamilyMembers();
      setState(() {
        _members = members;
        // Por defecto asignar al usuario activo
        _assignedToId = WearApiClient.instance.userId;
        _loadingMembers = false;
      });
    } catch (_) {
      setState(() {
        _assignedToId = WearApiClient.instance.userId;
        _loadingMembers = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: WearColors.headerTeal),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (!mounted) return;
    setState(() {
      _dueDate = DateTime(
        date.year, date.month, date.day,
        time?.hour ?? _dueDate.hour,
        time?.minute ?? _dueDate.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'El título es obligatorio');
      return;
    }
    if (_assignedToId == null) {
      setState(() => _error = 'Selecciona a quién asignar la tarea');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await WearTaskRepository().createTask(
        title: _titleCtrl.text.trim(),
        dueDate: _dueDate.toUtc().toIso8601String(),
        priority: _priority,
        assignedToId: _assignedToId!,
        description: _descCtrl.text.trim(),
      );

      // Recargar tareas del usuario activo y volver al inicio
      final userId = WearApiClient.instance.userId!;
      final tasks = await WearTaskRepository().getMyTasks(userId);
      final memberName = _members
          .where((m) => m.id == userId)
          .map((m) => m.name)
          .firstOrNull ?? '';

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TaskListScreen(
            userName: memberName,
            initialTasks: tasks,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancel() {
    final userId = WearApiClient.instance.userId!;
    WearTaskRepository().getMyTasks(userId).then((tasks) {
      if (!mounted) return;
      final memberName = _members
          .where((m) => m.id == userId)
          .map((m) => m.name)
          .firstOrNull ?? '';
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TaskListScreen(
            userName: memberName,
            initialTasks: tasks,
          ),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);

    return Scaffold(
      backgroundColor: WearColors.background,
      body: SafeArea(
        child: _loadingMembers
            ? const Center(
                child: CircularProgressIndicator(color: WearColors.headerTeal))
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'NUEVA TAREA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WearColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Título
                    _WearField(
                        controller: _titleCtrl,
                        hint: 'Título',
                        obscure: false),
                    const SizedBox(height: 6),

                    // Descripción
                    _WearField(
                        controller: _descCtrl,
                        hint: 'Descripción (opcional)',
                        obscure: false),
                    const SizedBox(height: 6),

                    // Fecha y hora
                    GestureDetector(
                      onTap: _pickDate,
                      child: _InfoTile(
                        icon: Icons.schedule_outlined,
                        label: _formatDate(_dueDate),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Prioridad
                    _DropdownTile<String>(
                      icon: Icons.flag_outlined,
                      value: _priority,
                      items: _priorities,
                      labelOf: (v) => v[0].toUpperCase() + v.substring(1),
                      onChanged: (v) => setState(() => _priority = v),
                    ),
                    const SizedBox(height: 6),

                    // Asignar a (solo guardianes pueden asignar a otros)
                    if (_isGuardian && _members.isNotEmpty)
                      _DropdownTile<String>(
                        icon: Icons.person_outline,
                        value: _assignedToId ?? _members.first.id,
                        items: _members.map((m) => m.id).toList(),
                        labelOf: (id) => _members
                            .firstWhere((m) => m.id == id,
                                orElse: () => _members.first)
                            .name,
                        onChanged: (v) => setState(() => _assignedToId = v),
                      ),

                    const SizedBox(height: 10),

                    if (_error != null) ...[
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Guardar
                    GestureDetector(
                      onTap: _saving ? null : _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: WearColors.headerTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'GUARDAR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Cancelar
                    GestureDetector(
                      onTap: _cancel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: WearColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: WearColors.cardShadow,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.close,
                                color: WearColors.headerTeal, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Cancelar',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: WearColors.textNavy),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year}  $h:$m';
  }
}

// ── Widgets compartidos ───────────────────────────────────────────────────────

class _WearField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _WearField(
      {required this.controller, required this.hint, required this.obscure});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 11, color: WearColors.textNavy),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 11, color: WearColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: WearColors.headerTeal.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: WearColors.headerTeal.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WearColors.headerTeal),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: WearColors.headerTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: WearColors.headerTeal, size: 14),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: WearColors.textNavy)),
        ],
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: WearColors.headerTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: WearColors.headerTeal, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 11, color: WearColors.textNavy),
                items: items
                    .map((i) => DropdownMenuItem<T>(
                        value: i, child: Text(labelOf(i))))
                    .toList(),
                onChanged: (v) { if (v != null) onChanged(v); },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
