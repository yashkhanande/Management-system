import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_snackbar.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/model/remark.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  //final MemberController memberController = Get.find<MemberController>();

  var tasks = <Task>[].obs;
  var projects = <Task>[].obs;
  var ownerTask = <Task>[].obs;
  var searchQuery = ''.obs;
  String? ownerId;
  var isLoading = false.obs;

  /// Filtered tasks based on search query — reactive.
  List<Task> get filteredTasks {
    final q = searchQuery.value.toLowerCase().trim();

    // 👇 show all if empty OR even 1 char works automatically
    if (q.isEmpty) return tasks.toList();

    final dashboardController = Get.find<DashboardController>();

    return tasks.where((t) {
      final title = (t.title).toLowerCase();
      final owner = (t.ownerId).toLowerCase();
      final memberName = (dashboardController
          .getMemberName(t.ownerId)
          .toLowerCase());
      print(
        "SEARCH DEBUG → ${t.title} | ${dashboardController.getMemberName(t.ownerId)}",
      );

      return title.contains(q) || owner.contains(q) || memberName.contains(q);
    }).toList();
  }

  void getProjects() {
    projects.value = tasks.where((task) => task.type == 'PROJECT').toList();
  }

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    ever(auth.isLoggedIn, (loggedIn) {
      if (loggedIn) {
        getAllTask();
        if (ownerId != null) getTaskByOwner(ownerId!);
      }
    });
    Future.microtask(() {
      if (auth.isLoggedIn.value && tasks.isEmpty) {
        getAllTask();
        if (ownerId != null) getTaskByOwner(ownerId!);
      }
    });
  }

  /// Refresh related controllers so dashboard/profile reflect changes.
  void _refreshRelated() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboard();
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }
  }

  Future<bool> addTask(Task task) async {
    isLoading.value = true;
    try {
      await _taskService.addTask(task);
      await getAllTask();
      _refreshRelated();
      return true;
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to add task: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllProjects() async {
    isLoading.value = true;
    try {
      projects.value = await _taskService.getTasksByType('PROJECT');
      getProjects();
    } catch (e) {
      print("Error fetching tasks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllTask() async {
    isLoading.value = true;
    try {
      tasks.value = await _taskService.getAllTask();
      getProjects();
    } catch (e) {
      print("Error fetching tasks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTask(String id, Task newTask) async {
    isLoading.value = true;
    try {
      await _taskService.updateTask(id, newTask);
      await getAllTask();
      _refreshRelated();
      return true;
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to update task: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTaskType(String id) async {
    isLoading.value = true;
    try {
      await _taskService.updateTaskType(id);
      await getAllTask();
      _refreshRelated();
      return true;
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to update task: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTaskByOwner(String id) async {
    isLoading.value = true;
    try {
      ownerTask.value = await _taskService.getTaskByOwner(id);
    } catch (e) {
      print('TaskController: Failed to fetch owner tasks — $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Task> getTaskById(String id) async {
    isLoading.value = true;
    try {
      return await _taskService.getTaskById(id);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      await getAllTask();
      _refreshRelated();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to remove task: $e');
    }
  }

  Future<bool> submitTaskForReview({
    required String taskId,
    required String actorId,
    required String actorRole,
  }) async {
    isLoading.value = true;
    try {
      await _taskService.transitionTaskStatus(
        taskId,
        'REVIEW',
        actorId: actorId,
        actorRole: actorRole,
      );
      await getAllTask();
      _refreshRelated();
      return true;
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to submit for review: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveTaskCompletion({
    required String taskId,
    required String actorId,
    required String actorRole,
  }) async {
    isLoading.value = true;
    try {
      await _taskService.transitionTaskStatus(
        taskId,
        'DONE',
        actorId: actorId,
        actorRole: actorRole,
      );
      await getAllTask();
      _refreshRelated();
      return true;
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to approve completion: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> disapproveTaskReview({
    required String taskId,
    required String actorId,
    required String actorRole,
  }) async {
    isLoading.value = true;
    try {
      await _taskService.transitionTaskStatus(
        taskId,
        'TODO',
        actorId: actorId,
        actorRole: actorRole,
      );
      await getAllTask();
      _refreshRelated();
      return true;
    } catch (e) {
      // Backward-compatible fallback for servers that only allow REVIEW/DONE transitions.
      try {
        final existing = await _taskService.getTaskById(taskId);
        final updated = Task(
          id: existing.id,
          title: existing.title,
          description: existing.description,
          priority: existing.priority,
          type: existing.type,
          status: 'TODO',
          category: existing.category,
          ownerId: existing.ownerId,
          parentId: existing.parentId,
          progress: existing.progress,
          contributionPercent: existing.contributionPercent,
          remark: existing.remark,
          deadLine: existing.deadLine,
          startDate: existing.startDate,
          remainingTask: existing.remainingTask,
          completedTask: existing.completedTask,
          criticalDays: existing.criticalDays,
          isProject: existing.isProject,
          collaborators: existing.collaborators,
          dependentTasks: existing.dependentTasks,
        );
        await _taskService.updateTask(taskId, updated);
        await getAllTask();
        _refreshRelated();
        return true;
      } catch (fallbackError) {
        AppSnackbar.show('Error', 'Failed to disapprove review: $fallbackError');
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addRemark(String senderId, String taskId, String message) async {
    isLoading.value = true;
    try {
      await _taskService.addRemark(senderId, taskId, message);
      await fetchRemarks(taskId);
      return true;
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to add remark: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  var remarkList = <Remark>[].obs;
  Future<void> fetchRemarks(String taskId) async {
    isLoading.value = true;
    try {
      remarkList.value = await _taskService.getRemarks(taskId);
    } catch (e) {
      remarkList.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkForSubmit(String taskId) async {
    isLoading.value = true;
    try {
      return await _taskService.checkForSubmit(taskId);
    } catch (e) {
      print('TaskController: Failed to check submission status — $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
