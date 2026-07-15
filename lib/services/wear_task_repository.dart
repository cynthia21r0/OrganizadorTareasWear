import 'package:dio/dio.dart';
import '../models/wear_task.dart';
import 'wear_api_client.dart';

class WearTaskRepository {
  final Dio _dio = WearApiClient.instance.dio;

  Future<List<WearTask>> getMyTasks(String userId) async {
    final response = await _dio.get('/tasks/user/$userId');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => WearTask.fromApiJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggleStatus(String taskId) async {
    await _dio.patch('/tasks/$taskId/toggle');
  }
}
