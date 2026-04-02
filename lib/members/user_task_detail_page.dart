import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/message_page.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/collaboration_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';

class UserTaskDetailPage extends StatefulWidget {
  final Task task;

  const UserTaskDetailPage({super.key, required this.task});

  @override
  State<UserTaskDetailPage> createState() => _UserTaskDetailPageState();
}

class _UserTaskDetailPageState extends State<UserTaskDetailPage> {
  final TaskController _taskController = Get.find<TaskController>();
  final RxList<Task> _subtasks = <Task>[].obs;
  final CollaborationController _collaborationController =
      Get.find<CollaborationController>();

  String _parentProjectName(String? parentId) {
    if (parentId == null || parentId.trim().isEmpty) return 'No parent project';

    final parent = _taskController.tasks.firstWhereOrNull(
      (t) =>
          t.id == parentId &&
          ((t.type ?? '').toUpperCase() == 'PROJECT' || t.isProject == true),
    );
    final title = parent?.title.trim() ?? '';
    return title.isEmpty ? 'Unknown project' : title;
  }

  String get _normalizedRole =>
      AuthController.to.role.value.trim().toUpperCase();

  String get _sessionUserId => AuthController.to.currentUserId.value.trim();

  String get _sessionUsername => AuthController.to.username.value.trim();

  bool get _isAdminSession => _normalizedRole == 'ADMIN';

  bool get _isTaskOwnerSession {
    final ownerId = widget.task.ownerId.trim();
    if (ownerId.isEmpty) return false;
    final normalizedOwner = ownerId.toLowerCase();

    bool matches(String candidate) {
      final value = candidate.trim();
      if (value.isEmpty) return false;
      return value.toLowerCase() == normalizedOwner;
    }

    return matches(_sessionUserId) || matches(_sessionUsername);
  }

  bool get _canModifyTask => _isAdminSession || _isTaskOwnerSession;

  void _openTaskEditor(Task task) {
    Get.to(
      () => AddTask(
        defaultType: 'TASK',
        parentId: task.parentId,
        taskToEdit: task,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
    final taskId = widget.task.id;
    if (taskId != null && taskId.isNotEmpty) {
      _collaborationController.getDependencies(taskId);
    }
  }

  void _loadSubtasks() {
    final taskId = widget.task.id;
    if (taskId == null || taskId.isEmpty) return;

    // Filter tasks where parentId matches this task
    _subtasks.value = _taskController.tasks
        .where((t) => t.parentId == taskId)
        .toList();
  }

  bool checkDependencies() {
    List<Task> dependencies = _collaborationController.dependencies();
    return dependencies.map((e) => e.status != "DONE").toList().isNotEmpty;
  }

  Future<void> _convertTaskToProjectAndAddSubtasks() async {
    final taskId = widget.task.id;
    if (taskId == null || taskId.isEmpty) {
      Get.snackbar(
        'Error',
        'Task id is missing. Please refresh and try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final alreadyProject = (widget.task.type ?? '').toUpperCase() == 'PROJECT';

    if (!alreadyProject) {
      final evolvedTask = Task(
        id: widget.task.id,
        title: widget.task.title,
        description: widget.task.description,
        priority: widget.task.priority,
        type: widget.task.type,
        status: widget.task.status,
        ownerId: widget.task.ownerId,
        parentId: widget.task.parentId,
        progress: widget.task.progress,
        contributionPercent: 0,
        remark: widget.task.remark,
        deadLine: widget.task.deadLine,
        startDate: widget.task.startDate,
        remainingTask: widget.task.remainingTask,
        completedTask: widget.task.completedTask,
      );

      await _taskController.updateTask(taskId, evolvedTask);
      await _taskController.getAllTask();
    }

    final result = await Get.to(
      () => AddTask(defaultType: 'TASK', parentId: taskId),
    );

    // Refresh subtasks when returning from add page
    if (result == true) {
      await _taskController.getAllTask();
    }
    _loadSubtasks();
  }

  Future<void> _submitForReview() async {
    final taskId = widget.task.id;
    if (taskId == null || taskId.isEmpty) {
      Get.snackbar(
        'Error',
        'Task id is missing. Please refresh and try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    final canSubmit = await _taskController.checkForSubmit(taskId);
    if (!canSubmit) {
      Get.snackbar(
        'Error',
        'Failed to submit for review: some dependencies are not met.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _taskController.submitTaskForReview(
      taskId: taskId,
      actorId: widget.task.ownerId,
      actorRole: AuthController.to.role.value,
    );

    if (ok) {
      setState(() {
        widget.task.status = 'REVIEW';
      });
      Get.snackbar(
        'Submitted',
        'Task submitted for project-owner review.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final task = widget.task;
    final parentProjectName = _parentProjectName(task.parentId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.alertTitle],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: Get.back,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    task.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      height: 1.02,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 2),
                                  Text(
                                    task.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.folder_open_rounded,
                                        size: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          parentProjectName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                final taskId = task.id;
                                if (taskId == null || taskId.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Task id is missing. Please refresh and try again.',
                                    backgroundColor: AppColors.error,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                Get.to(
                                  () => const MessagePage(),
                                  arguments: taskId,
                                );
                              },
                              child: const Icon(
                                Icons.message,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_canModifyTask)
                        IconButton(
                          onPressed: () => _openTaskEditor(task),
                          tooltip: 'Modify task',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Task status info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Status: ${task.status ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.stripColor(
                                  priority: task.priority,
                                  status: task.status,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                            Text(
                              '${task.progress}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: (task.progress / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.stripColor(
                                priority: task.priority,
                                status: task.status,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Task details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          label: 'Parent Project',
                          value: parentProjectName,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Description', value: task.description),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Priority',
                          value: task.priority.toUpperCase(),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Status', value: task.status ?? 'N/A'),
                        if (task.deadLine != null) ...[
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Deadline',
                            value:
                                "${task.deadLine!.day}/${task.deadLine!.month}/${task.deadLine!.year}",
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final dependencies = _collaborationController.dependencies
                        .toList();

                    if (dependencies.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.link,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Dependencies',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              Text(
                                '${dependencies.length}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// 🔹 List
                          Column(
                            children: dependencies.map((dep) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.08),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    /// Status Indicator
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(dep.status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    /// Title + Status
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dep.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dep.status ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  // Buttons section
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _convertTaskToProjectAndAddSubtasks();
                          },
                          icon: const Icon(Icons.add_task_rounded, size: 18),
                          label: const Text('Add Subtasks'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if ((task.type ?? '').toUpperCase() == 'TASK' &&
                          !AppColors.isCompletedStatus(task.status) &&
                          (task.status ?? '').toUpperCase() != 'REVIEW') ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _submitForReview();
                            },
                            icon: const Icon(Icons.rule_rounded, size: 18),
                            label: const Text('Submit Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                33,
                                189,
                                33,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Subtasks section
                  Text(
                    'Subtasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (_subtasks.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Center(
                          child: Text(
                            'No subtasks yet. Click "Add Subtasks" to create one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: _subtasks
                          .map((subtask) => _SubtaskCard(subtask: subtask))
                          .toList(),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }
}

class _SubtaskCard extends StatelessWidget {
  final Task subtask;

  const _SubtaskCard({required this.subtask});

  @override
  Widget build(BuildContext context) {
    final isDone = AppColors.isCompletedStatus(subtask.status);
    final statusColor = AppColors.stripColor(
      priority: subtask.priority,
      status: subtask.status,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.pending_outlined,
              size: 16,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtask.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtask.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              subtask.status ?? 'TODO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
