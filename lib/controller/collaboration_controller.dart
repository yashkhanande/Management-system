import 'package:get/get.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class CollaborationController extends GetxController {
  var collaborators = <Task>[].obs;
  var projects = <Task>[].obs;

  void addCollaborator(String taskId, String _projectId) async {
    try {
      await TaskService().addCollaborator(taskId, _projectId);

      print('CollaborationController: Added collaborator $_projectId to task $taskId');
    } catch (e) {
      print('Error adding collaborator: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllProjects();
   
  }

  Future<void> fetchAllProjects() async {
    try {
      final results = await TaskService().getAllProjects();
      projects.value = results;
      print('CollaborationController: Fetched ${projects.length} projects');
      projects.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch all projects — $e');
      projects.value = [];
    }
  }

  Future<void> getCollaboratedProjects(String projectId) async {
    try {
      final results = await TaskService().getCollaboratedProjects(projectId);
      collaborators.value = results;
      print('CollaborationController: Fetched ${collaborators.length} collaborators for project $projectId');
      collaborators.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('CollaborationController: Failed to fetch collaborators — $e');
      collaborators.value = [];
    }
  }
}
