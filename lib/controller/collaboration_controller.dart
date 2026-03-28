import 'package:get/get.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class CollaborationController extends GetxController {
  final RxList<Task> collaborators = <Task>[].obs;
  final RxList<Task> projects = <Task>[].obs;

  final RxBool isLoadingCollaborators = false.obs;
  final RxBool isLoadingProjects = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString lastError = ''.obs;

  String _activeProjectId = '';

  Future<void> initializeForProject(String projectId) async {
    _activeProjectId = projectId.trim();
    if (_activeProjectId.isEmpty) return;

    await Future.wait([
      fetchAllProjects(),
      getCollaboratedProjects(_activeProjectId),
    ]);
  }

  Future<void> refreshActiveProject() async {
    if (_activeProjectId.isEmpty) return;
    await initializeForProject(_activeProjectId);
  }

  Future<void> fetchAllProjects() async {
    isLoadingProjects.value = true;
    try {
      final results = await TaskService().getAllProjects();
      projects.assignAll(results);
    } catch (e) {
      projects.clear();
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      isLoadingProjects.value = false;
    }
  }

  Future<void> getCollaboratedProjects(String projectId) async {
    final normalized = projectId.trim();
    if (normalized.isEmpty) return;

    _activeProjectId = normalized;
    isLoadingCollaborators.value = true;

    try {
      final results = await TaskService().getCollaboratedProjects(normalized);
      collaborators.assignAll(results);
    } catch (e) {
      collaborators.clear();
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      isLoadingCollaborators.value = false;
    }
  }

  List<Task> availableProjectsFor(
    String currentProjectId, {
    String searchQuery = '',
  }) {
    final current = currentProjectId.trim().toLowerCase();
    final query = searchQuery.trim().toLowerCase();

    final collaboratorIds = collaborators
        .map((task) => (task.id ?? '').trim().toLowerCase())
        .where((id) => id.isNotEmpty)
        .toSet();

    return projects.where((project) {
      final id = (project.id ?? '').trim();
      if (id.isEmpty) return false;

      final normalizedId = id.toLowerCase();
      if (normalizedId == current) return false;
      if (collaboratorIds.contains(normalizedId)) return false;

      if (query.isEmpty) return true;
      return project.title.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query) ||
          project.ownerId.toLowerCase().contains(query);
    }).toList();
  }

  Future<bool> addCollaborator({
    required String taskId,
    required String collaboratorProjectId,
  }) async {
    final sourceId = taskId.trim();
    final targetId = collaboratorProjectId.trim();

    if (sourceId.isEmpty || targetId.isEmpty) {
      lastError.value = 'Invalid project selection.';
      return false;
    }

    if (sourceId.toLowerCase() == targetId.toLowerCase()) {
      lastError.value =
          'The current project cannot be added as its own collaborator.';
      return false;
    }

    isSubmitting.value = true;
    lastError.value = '';

    try {
      await TaskService().addCollaborator(sourceId, targetId);
      await getCollaboratedProjects(sourceId);
      return true;
    } catch (e) {
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
