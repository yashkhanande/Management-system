import 'dart:convert';
import 'package:managementt/model/remark.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/api_service.dart';

class TaskService {
  final ApiService _api = ApiService();

  Future<void> addTask(Task task) async {
    final response = await _api.post('/tasks/add', body: task.toJson());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to add task',
      );
    }
  }

  Future<void> addCollaborator(String taskId, String projectId) async {
    final response = await _api.post(
      '/tasks/collaboratedProject/add/$taskId',
      body: projectId,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to add collaborator',
      );
    }
  }

  Future<void> addDependency(String taskId, String dependencyId) async {
    // taskId = "69c6d95c15a8b550f2894b2c";
    // dependencyId = "69c68c63fe54cc2683bb0593";
    print("inside add $taskId");
    print("inside add  dependencyId $dependencyId");
    final response = await _api.post(
      '/tasks/dependency/add/$taskId',
      body: dependencyId,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to add dependency',
      );
    }
  }

  Future<Task> getTaskById(String id) async {
    final response = await _api.get('/tasks/id/$id');
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get task');
    }
  }

  /// Fetch tasks by type (PROJECT or TASK).
  Future<List<Task>> getTasksByType(String type) async {
    final response = await _api.get('/tasks/allTasks/$type');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tasks of type $type');
    }
  }

  /// Fetch all tasks (both PROJECT and TASK types combined).
  Future<List<Task>> getAllTask() async {
    final results = await Future.wait([
      getTasksByType('PROJECT'),
      getTasksByType('TASK'),
    ]);
    return [...results[0], ...results[1]];
  }

  Future<List<Task>> getAllProjects() async {
    final response = await _api.get('/tasks/projects');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch projects');
    }
  }

  Future<List<Task>> getTaskByOwner(String id) async {
    final response = await _api.get('/tasks/member/$id');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch tasks for owner');
    }
  }

  Future<List<Task>> getCollaboratedProjects(String id) async {
    final response = await _api.get('/tasks/getCollaboratedProject/$id');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch collaborators ' + response.body);
    }
  }

  Future<void> updateTask(String id, Task newTask) async {
    final response = await _api.put(
      '/tasks/update/$id',
      body: newTask.toJson(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to update task',
      );
    }
  }

  Future<void> updateTaskType(String id) async {
    final response = await _api.put('/tasks/updateType/$id', body: true);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to update task',
      );
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await _api.delete('/tasks/delete/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to delete task',
      );
    }
  }

  Future<void> transitionTaskStatus(
    String id,
    String status, {
    required String actorId,
    required String actorRole,
  }) async {
    final encodedActorId = Uri.encodeComponent(actorId);
    final encodedRole = Uri.encodeComponent(actorRole);
    final response = await _api.put(
      '/tasks/$id/status/transition/$status?actorId=$encodedActorId&actorRole=$encodedRole',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to transition task status',
      );
    }
  }

  /// Get total count of tasks by type.
  Future<int> getTaskCountByType(String type) async {
    final response = await _api.get('/tasks/TaskCount/$type');
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    } else {
      throw Exception('Failed to get task count');
    }
  }

  /// Trigger overdue check on the server.
  /// This marks tasks/projects as OVERDUE if their deadline has passed.
  Future<void> checkOverdue() async {
    try {
      await _api.post('/tasks/check-overdue');
    } catch (e) {
      // Silently fail - overdue check is not critical
      print('TaskService: Failed to check overdue — $e');
    }
  }

  Future<Map<String, List<Task>>> getAllTasksByCollaboration(String id) async {
    try {
      final response = await _api.get('/tasks/getAllTasksByCollaboration/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data.map((key, value) {
          final List list = value;
          return MapEntry(key, list.map((e) => Task.fromJson(e)).toList());
        });
      } else {
        throw Exception('Failed to fetch collaborated tasks');
      }
    } catch (e) {
      print('TaskService: Failed — $e');
      return {};
    }
  }

  Future<void> addRemark(String senderId, String taskId, String message) async {
    final response = await _api.post(
      '/tasks/remark/add/$taskId',
      body: {'senderId': senderId, 'message': message},
    );
    print(senderId);
    print(taskId);
    print(message);

    if (response.statusCode == 200) {
      print("Remark added successfully to id: $taskId");
    } else if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to add remark',
      );
    }
  }

  Future<List<Remark>> getRemarks(String taskId) async {
    final response = await _api.get('/tasks/getAllRemarks/$taskId');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Remark>.from(data.map((e) => Remark.fromJson(e)));
    } else {
      throw Exception('Failed to fetch remarks');
    }
  }
}
