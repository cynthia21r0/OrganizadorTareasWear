import 'package:flutter/material.dart';

enum WearTaskStatus { pendiente, completada }

class WearTask {
  final String id;
  final String title;
  final String timeLabel;
  final IconData icon;
  final WearTaskStatus status;

  const WearTask({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.icon,
    this.status = WearTaskStatus.pendiente,
  });

  WearTask copyWith({WearTaskStatus? status}) {
    return WearTask(
      id: id,
      title: title,
      timeLabel: timeLabel,
      icon: icon,
      status: status ?? this.status,
    );
  }

  factory WearTask.fromApiJson(Map<String, dynamic> json) {
    return WearTask(
      id: json['id'] as String,
      title: (json['title'] as String).toUpperCase(),
      timeLabel: _formatTime(json['dueDate'] as String),
      icon: _iconForTitle(json['title'] as String),
      status: json['status'] == 'completada'
          ? WearTaskStatus.completada
          : WearTaskStatus.pendiente,
    );
  }

  static String _formatTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute hrs';
  }

  static IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('cuarto') || t.contains('cama') || t.contains('ordenar')) {
      return Icons.bed_outlined;
    }
    if (t.contains('deber') || t.contains('tarea') || t.contains('estudi')) {
      return Icons.menu_book_outlined;
    }
    if (t.contains('guitarra') ||
        t.contains('música') ||
        t.contains('musica')) {
      return Icons.music_note_outlined;
    }
    if (t.contains('platos') || t.contains('cocina')) {
      return Icons.local_dining_outlined;
    }
    if (t.contains('basura')) {
      return Icons.delete_outline;
    }
    return Icons.check_circle_outline;
  }
}
