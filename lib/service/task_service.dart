import 'dart:convert';
import 'package:managementt/config.dart';
import 'package:http/http.dart' as http;
import 'package:managementt/model/task.dart';

class TaskService {
  final String baseUrl = "${Config.baseUrl}/tasks";

  String _basicAuth() {
    String username = "yash"; // later you will take from login
    String password = "1234";

    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  Future<void> addTask(Task task) async {
    await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _basicAuth(),
      },
      body: jsonEncode(task.toJson()),
    );
  }

  Future<Task> getTaskById(String Id) async {
    final responce = await http.get(
      Uri.parse("$baseUrl/id/$Id"),
      headers: {"Authorization": _basicAuth()},
    );
    if (responce.statusCode == 200) {
      Task data = jsonDecode(responce.body);
      return data;
    } else {
      throw Exception("Failed to get task");
    }
  }

  Future<List<Task>> getAllTask() async {
    final responce = await http.get(
      Uri.parse("$baseUrl/AllTasks"),
      headers: {"Authorization": _basicAuth()},
    );
    if (responce.statusCode == 200) {
      List data = jsonDecode(responce.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<List<Task>> getTaskByOwner(String id) async {
    final responce = await http.get(
      Uri.parse("$baseUrl/member/$id"),
      headers: {"Authorization": _basicAuth()},
    );
    if (responce.statusCode == 200) {
      List data = jsonDecode(responce.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch tasks for owner");
    }
  }

  Future<void> updateTask(String id, Task newTask) async {
    await http.put(
      Uri.parse("$baseUrl/update/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _basicAuth(),
      },
      body: jsonEncode(newTask.toJson()),
    );
  }

  Future<void> deleteTask(String id) async {
    await http.delete(
      Uri.parse("$baseUrl/delete/$id"),
      headers: {"Authorization": _basicAuth()},
    );
  }
}
