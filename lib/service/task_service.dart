import 'dart:convert';
import 'package:managementt/config.dart';
import 'package:http/http.dart' as http;
import 'package:managementt/model/task.dart';

class TaskService {
  final String baseUrl = "${Config.baseUrl}/tasks";

  Future<void> addTask(Task task) async {
    await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );
  }

  Future<Task> getTaskById(String Id) async {
    final responce = await http.get(Uri.parse("$baseUrl/id/$Id"));
    if (responce.statusCode == 200) {
      Task data = jsonDecode(responce.body);
      return data;
    } else {
      throw Exception("Failed to get task");
    }
  }

  Future<List<Task>> getAllTask() async {
    final responce = await http.get(Uri.parse("$baseUrl/AllTasks"));
    if (responce.statusCode == 200) {
      List data = jsonDecode(responce.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<List<Task>> getTaskByOwner(String id) async {
    final responce = await http.get(Uri.parse("$baseUrl/member/$id"));
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
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(newTask.toJson()),
    );
  }

  Future<void> deleteTask(String id) async {
    await http.delete(Uri.parse("$baseUrl/delete/$id"));
  }
}
