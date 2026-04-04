import 'package:get/get.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class CollaborationController extends GetxController {
  var collaborators = <Task>[].obs;
  var projects = <Task>[].obs;
  var tasksOfCollaboration = <String, List<Task>>{}.obs;
  var dependencies = <Task>[].obs;

  var isLoading = false.obs;

  void addCollaborator(String taskId, String _projectId) async {
    try {
      await TaskService().addCollaborator(taskId, _projectId);
      getCollaboratedProjects(taskId);
      print(
        'CollaborationController: Added collaborator $_projectId to task $taskId',
      );
    } catch (e) {
      print('Error adding collaborator: $e');
    }
  }

  void removeCollaborator(String taskId, String projectId) async {
    try {
      await TaskService().removeCollaborator(taskId, projectId);
      getCollaboratedProjects(taskId);
      print(
        'CollaborationController: Removed collaborator $projectId from task $taskId',
      );
    } catch (e) {
      print('Error removing collaborator: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllProjects();
  }

  Future<void> fetchAllProjects() async {
    try {
      isLoading.value = true;
      final results = await TaskService().getAllProjects();
      projects.value = results;
      print('CollaborationController: Fetched ${projects.length} projects');
      projects.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch all projects — $e');
      projects.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCollaboratedProjects(String projectId) async {
    try {
      final results = await TaskService().getCollaboratedProjects(projectId);
      collaborators.value = results;

      collaborators.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('CollaborationController: Failed to fetch collaborators — $e');
      collaborators.value = [];
    }
  }

  Future<void> getDependencies(String projectId) async {
    try {
      final results = await TaskService().getDependencies(projectId);
      dependencies.value = results;

      dependencies.refresh();
      print(
        'CollaborationController: Fetched ${dependencies.length} dependencies',
      );
    } catch (e) {
      // ignore: avoid_print
      print('CollaborationController: Failed to fetch dependencies — $e');
      dependencies.value = [];
    }
  }

  var loadingTasks = false.obs;

  Future<void> getAllTasksByCollaboration(String projectId) async {
    try {
      loadingTasks.value = true;
      final results = await TaskService().getAllTasksByCollaboration(projectId);

      tasksOfCollaboration.value = results;

      // Calculate total tasks (not just project count)
      int totalTasks = results.values.fold(0, (sum, list) => sum + list.length);

      print(
        'CollaborationController: Fetched $totalTasks tasks across ${results.length} projects for collaboration $projectId',
      );
    } catch (e) {
      print('CollaborationController: Failed to fetch tasks — $e');
      tasksOfCollaboration.value = {};
    } finally {
      loadingTasks.value = false;
    }
  }

  Future<void> getAllTasksByCollaboration2(
    String projectId,
    String taskId,
  ) async {
    try {
      loadingTasks.value = true;

      final results = await TaskService().getAllTasksByCollaboration(projectId);

      // Create a new map to avoid mutating original reference
      final updatedResults = results.map((key, taskList) {
        final filteredList = taskList
            .where((task) => task.id != taskId)
            .toList();

        return MapEntry(key, filteredList);
      });

      tasksOfCollaboration.value = updatedResults;

      // Calculate total tasks correctly
      int totalTasks = updatedResults.values.fold(
        0,
        (sum, list) => sum + list.length,
      );

      print(
        'CollaborationController: Fetched $totalTasks tasks across ${updatedResults.length} projects for collaboration $projectId',
      );
    } catch (e) {
      print('CollaborationController: Failed to fetch tasks — $e');

      // Assign empty map safely
      tasksOfCollaboration.value = {};
    } finally {
      loadingTasks.value = false;
    }
  }

  void addDependency(String taskId, String dependencyId) async {
    try {
      await TaskService().addDependency(taskId, dependencyId);
      print(
        'CollaborationController: Added dependency $dependencyId to task $taskId',
      );
    } catch (e) {
      print('Error adding dependency: $e');
    }
  }
}
