import 'package:get/state_manager.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class UserTaskController extends GetxController {
  final TaskService _taskService = TaskService();
  var userTasks = <Task>[].obs;
  var userProjects = <Task>[].obs;

  Future<void> fetchUserProjects(String userId) async {
    try {
      final results = await _taskService.getTaskByOwner(userId);

      // Prefer using the member endpoint response, but ensure we only keep projects.
      var projects = results
          .where((t) => t.type == 'PROJECT' || t.isProject == true)
          .toList();

      // If the member endpoint returned nothing (or no projects), try a fallback:
      if (projects.isEmpty) {
        // ignore: avoid_print
        print(
          'UserTaskController: member endpoint returned no projects for $userId — falling back to all tasks',
        );
        final all = await _taskService.getAllTask();
        projects = all
            .where(
              (t) =>
                  (t.ownerId == userId) &&
                  (t.type == 'PROJECT' || t.isProject == true),
            )
            .toList();
      }
      userProjects.value = projects;
      userProjects.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch user tasks — $e');
      userTasks.value = [];
    }
  }

  Future<void> fetchUserTasks(String userId) async {
    try {
      final results = await _taskService.getTaskByOwner(userId);
      var tasks = results
          .where((t) => t.type == 'TASK' && t.isProject == false)
          .toList();

      // If the member endpoint returned nothing (or no tasks), try a fallback:
      if (tasks.isEmpty) {
        // ignore: avoid_print
        print(
          'UserTaskController: member endpoint returned no tasks for $userId — falling back to all tasks',
        );
        final all = await _taskService.getAllTask();
        tasks = all
            .where(
              (t) =>
                  (t.ownerId == userId) &&
                  (t.type == 'TASK' || t.isProject == false),
            )
            .toList();
      }
      userTasks.value = tasks;
      userTasks.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch user tasks — $e');
      userTasks.value = [];
    }
  }


  

}
