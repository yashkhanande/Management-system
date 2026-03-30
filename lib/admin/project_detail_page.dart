import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/message_page.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/collaboration_controller.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/members/collaboration_page.dart';
import 'package:managementt/model/task.dart';

class ProjectDetailPage extends StatefulWidget {
  final Task project;
  final List<String> projectMemberNames;

  const ProjectDetailPage({
    super.key,
    required this.project,
    this.projectMemberNames = const [],
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final TaskController _taskController = Get.find<TaskController>();
  final MemberController _memberController = Get.find<MemberController>();
  final RxString _selectedFilter = 'ALL'.obs;
  final RxString _taskSearchQuery = ''.obs;
  final CollaborationController collaborationController =
      Get.find<CollaborationController>();

  void _openProjectEditor(Task project) {
    Get.to(() => AddTask(defaultType: 'PROJECT', taskToEdit: project));
  }

  void _openTaskEditor(Task task) {
    Get.to(
      () => AddTask(
        defaultType: task.type ?? 'TASK',
        parentId: task.parentId,
        taskToEdit: task,
      ),
    );
  }

  Future<void> _undoCompletedTask(Task task) async {
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

    if (!_canApproveTasks) {
      Get.snackbar(
        'Action blocked',
        'Only the project owner or an admin can undo this task.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (!AppColors.isCompletedStatus(task.status)) {
      Get.snackbar(
        'Not allowed',
        'Only tasks marked done can be undone.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    final updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      type: task.type,
      status: 'TODO',
      ownerId: task.ownerId,
      parentId: task.parentId,
      progress: 0,
      contributionPercent: task.contributionPercent,
      remark: task.remark,
      deadLine: task.deadLine,
      startDate: task.startDate,
      remainingTask: task.remainingTask,
      completedTask: task.completedTask,
      criticalDays: task.criticalDays,
      isProject: task.isProject,
    );

    final ok = await _taskController.updateTask(taskId, updated);
    if (ok) {
      Get.snackbar(
        'Task reopened',
        'Task marked as TODO and re-allocated to ${_memberNameById(task.ownerId)}.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _approveTask(Task task) async {
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

    if (!_canApproveTasks) {
      Get.snackbar(
        'Action blocked',
        'Only the project owner or an admin can approve this task.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final role = _normalizedRole;
    final actorId = _resolveActorIdForApproval();

    if (actorId.isEmpty) {
      Get.snackbar(
        'Action blocked',
        'We could not resolve your identity for approval. Please relaunch or contact an admin.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _taskController.approveTaskCompletion(
      taskId: taskId,
      actorId: actorId,
      actorRole: role,
    );

    if (ok) {
      Get.snackbar(
        'Approved',
        'Task marked as done after review.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (_memberController.members.isEmpty &&
        !_memberController.isLoading.value) {
      _memberController.getMembers();
    }
  }

  List<Task> get _projectTasks {
    final parentId = widget.project.id;
    if (parentId == null || parentId.isEmpty) {
      return <Task>[];
    }

    var all = _taskController.tasks.where((t) {
      final isTask = (t.type ?? '').toUpperCase() == 'TASK';
      return isTask && t.parentId == parentId;
    }).toList();

    // Apply search filter
    final searchQuery = _taskSearchQuery.value.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      all = all.where((t) {
        final titleMatch = t.title.toLowerCase().contains(searchQuery);
        final ownerName = _memberNameById(t.ownerId).toLowerCase();
        final ownerMatch = ownerName.contains(searchQuery);
        return titleMatch || ownerMatch;
      }).toList();
    }

    // Apply status filter
    final f = _selectedFilter.value;
    if (f == 'ALL') return all;

    return all.where((t) {
      final status = (t.status ?? '').toUpperCase();
      switch (f) {
        case 'TODO':
          return status == 'TODO' || status == 'NOT_STARTED';
        case 'IN_PROGRESS':
          return status == 'IN_PROGRESS';
        case 'REVIEW':
          return status == 'REVIEW';
        case 'OVERDUE':
          return status == 'OVERDUE';
        case 'DONE':
          return status == 'DONE' || status == 'COMPLETED';
        default:
          return true;
      }
    }).toList();
  }

  int _countFor(String filter) {
    final parentId = widget.project.id;
    if (parentId == null || parentId.isEmpty) return 0;

    final all = _taskController.tasks.where((t) {
      final isTask = (t.type ?? '').toUpperCase() == 'TASK';
      return isTask && t.parentId == parentId;
    }).toList();

    switch (filter) {
      case 'ALL':
        return all.length;
      case 'TODO':
        return all
            .where(
              (t) =>
                  (t.status ?? '').toUpperCase() == 'TODO' ||
                  (t.status ?? '').toUpperCase() == 'NOT_STARTED',
            )
            .length;
      case 'IN_PROGRESS':
        return all
            .where((t) => (t.status ?? '').toUpperCase() == 'IN_PROGRESS')
            .length;
      case 'REVIEW':
        return all
            .where((t) => (t.status ?? '').toUpperCase() == 'REVIEW')
            .length;
      case 'OVERDUE':
        return all
            .where((t) => (t.status ?? '').toUpperCase() == 'OVERDUE')
            .length;
      case 'DONE':
        return all
            .where(
              (t) =>
                  (t.status ?? '').toUpperCase() == 'DONE' ||
                  (t.status ?? '').toUpperCase() == 'COMPLETED',
            )
            .length;
      default:
        return 0;
    }
  }

  String _deadlineText(DateTime? d) {
    return DateTimeHelper.remainingDaysLabel(d);
  }

  String _dateShort(DateTime? d) {
    if (d == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Color _remainingTimeColor(int daysLeft) {
    if (daysLeft <= 10) {
      return AppColors.error;
    }
    if (daysLeft <= 25) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _memberShort(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '?';
    if (clean.length == 1) return clean.toUpperCase();
    return clean.substring(0, 2).toUpperCase();
  }

  String _memberNameById(String ownerId) {
    final match = _memberController.members.firstWhereOrNull(
      (m) => m.id == ownerId,
    );
    final name = match?.name.trim() ?? '';
    return name.isEmpty ? ownerId : name;
  }

  String get _projectOwnerId => widget.project.ownerId.trim();

  String get _normalizedRole =>
      AuthController.to.role.value.trim().toUpperCase();

  String get _currentUsername => AuthController.to.username.value.trim();

  bool get _isAdminSession => _normalizedRole == 'ADMIN';

  String _resolvedMemberIdFromSession() {
    final username = _currentUsername.toLowerCase();
    if (username.isEmpty) return '';

    final member = _memberController.members.firstWhereOrNull((m) {
      final email = (m.email ?? '').trim().toLowerCase();
      final id = (m.id ?? '').trim().toLowerCase();
      final name = m.name.trim().toLowerCase();
      return username == email || username == id || username == name;
    });

    if (member != null && (member.id ?? '').trim().isNotEmpty) {
      return member.id!.trim();
    }

    final stored = AuthController.to.currentUserId.value.trim();
    return stored;
  }

  bool get _isProjectOwnerSession {
    final ownerId = _projectOwnerId;
    if (ownerId.isEmpty) return false;
    final normalizedOwner = ownerId.toLowerCase();

    bool matches(String candidate) {
      final value = candidate.trim();
      if (value.isEmpty) return false;
      return value.toLowerCase() == normalizedOwner;
    }

    return matches(_resolvedMemberIdFromSession()) ||
        matches(AuthController.to.currentUserId.value) ||
        matches(_currentUsername);
  }

  bool get _canManageProject => _isAdminSession || _isProjectOwnerSession;

  bool get _canApproveTasks => _canManageProject;

  String _resolveActorIdForApproval() {
    if (_isAdminSession) {
      final adminId = AuthController.to.currentUserId.value.trim();
      if (adminId.isNotEmpty) {
        return adminId;
      }
      final adminUsername = _currentUsername;
      return adminUsername.isNotEmpty ? adminUsername : 'ADMIN';
    }

    final ownerId = _projectOwnerId;
    if (ownerId.isNotEmpty) {
      return ownerId;
    }

    return _resolvedMemberIdFromSession();
  }

  List<String> _projectMembers(List<Task> tasks) {
    final result = <String>[];

    for (final name in widget.projectMemberNames) {
      final n = name.trim();
      if (n.isNotEmpty && !result.contains(n)) {
        result.add(n);
      }
    }

    final projectOwner = _memberNameById(widget.project.ownerId);
    if (projectOwner.isNotEmpty && !result.contains(projectOwner)) {
      result.add(projectOwner);
    }

    for (final t in tasks) {
      final ownerName = _memberNameById(t.ownerId);
      if (ownerName.isNotEmpty && !result.contains(ownerName)) {
        result.add(ownerName);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final project = widget.project;
    final remainingTimeProgress = DateTimeHelper.remainingTimeRatio(
      project.startDate,
      project.deadLine,
    );
    final remainingDays = DateTimeHelper.remainingDays(project.deadLine);
    final timeRemainingColor = _remainingTimeColor(remainingDays);
    final projectProgress = (project.progress / 100).clamp(0.0, 1.0);

    collaborationController.getAllTasksByCollaboration(project.id!);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        final tasks = _projectTasks;
        final members = _projectMembers(tasks);
        final doneCount = _countFor('DONE');
        final todoCount = _countFor('TODO');
        final inProgressCount = _countFor('IN_PROGRESS');
        final overdueCount = tasks
            .where((t) => (t.status ?? '').toUpperCase() == 'OVERDUE')
            .length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  height: 1.02,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Project Leader: ${_memberNameById(project.ownerId)}',
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (_canManageProject)
                          IconButton(
                            onPressed: () => _openProjectEditor(project),
                            tooltip: 'Modify project',
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            Get.to(
                              () => CollaborationPage(),
                              arguments: project.id,
                            );
                          },
                          icon: const Icon(Icons.people, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateShort(project.startDate),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.stripColor(
                                    priority: project.priority,
                                    status: project.status,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _deadlineText(project.deadLine),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                _dateShort(project.deadLine),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Project Progress',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${project.progress}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: projectProgress,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.stripColor(
                                  priority: project.priority,
                                  status: project.status,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time Remaining',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                '${_dateShort(project.startDate)} - ${_dateShort(project.deadLine)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _deadlineText(project.deadLine),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: remainingTimeProgress.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                timeRemainingColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Task Snapshot',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.assignment_rounded,
                                  count: _countFor('ALL'),
                                  label: 'Total',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.check_box_rounded,
                                  count: doneCount,
                                  label: 'Done',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.loop_rounded,
                                  count: inProgressCount,
                                  label: 'Active',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.rate_review_rounded,
                                  count: _countFor('REVIEW'),
                                  label: 'Review',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.warning_amber_rounded,
                                  count: overdueCount,
                                  label: 'Overdue',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Project Members',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  Get.to(
                                    () => MessagePage(),
                                    arguments: project.id,
                                  );
                                },
                                child: const Icon(Icons.message),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 14,
                            runSpacing: 12,
                            children: members
                                .map(
                                  (name) => SizedBox(
                                    width: 58,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.primaries[name.hashCode
                                                        .abs() %
                                                    Colors.primaries.length],
                                          ),
                                          child: Center(
                                            child: Text(
                                              _memberShort(name),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          name,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF374151),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => AddTask(
                            defaultType: 'TASK',
                            parentId: widget.project.id,
                          ),
                          arguments: widget.project.id,
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B5BEE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Task Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  onChanged: (val) => _taskSearchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: "Search tasks by name or assignee…",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B5BEE)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: _countFor('ALL'),
                        selected: _selectedFilter.value == 'ALL',
                        onTap: () => _selectedFilter.value = 'ALL',
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Todo',
                        count: todoCount,
                        selected: _selectedFilter.value == 'TODO',
                        onTap: () => _selectedFilter.value = 'TODO',
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'In Progress',
                        count: inProgressCount,
                        selected: _selectedFilter.value == 'IN_PROGRESS',
                        onTap: () => _selectedFilter.value = 'IN_PROGRESS',
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Review',
                        count: _countFor('REVIEW'),
                        selected: _selectedFilter.value == 'REVIEW',
                        onTap: () => _selectedFilter.value = 'REVIEW',
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Overdue',
                        count: overdueCount,
                        selected: _selectedFilter.value == 'OVERDUE',
                        onTap: () => _selectedFilter.value = 'OVERDUE',
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Done',
                        count: doneCount,
                        selected: _selectedFilter.value == 'DONE',
                        onTap: () => _selectedFilter.value = 'DONE',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 60),
                  child: Center(
                    child: Text(
                      'No tasks found for this project',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: tasks.map((t) {
                      final status = (t.status ?? '').toUpperCase();
                      final showApprove =
                          status == 'REVIEW' && _canApproveTasks;
                      return _TaskCard(
                        task: t,
                        deadlineText: _deadlineText(t.deadLine),
                        ownerName: _memberNameById(t.ownerId),
                        onModify: _canManageProject
                            ? () => _openTaskEditor(t)
                            : null,
                        onUndone:
                            _canManageProject &&
                                AppColors.isCompletedStatus(t.status)
                            ? () => _undoCompletedTask(t)
                            : null,
                        onApprove: showApprove ? () => _approveTask(t) : null,
                        onAddDependency: () => _openAddDependency(t),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 28),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openAddDependency(Task task) {
    final _collaborationController = Get.find<CollaborationController>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // 🔹 Drag Handle
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Dependency",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Content
                  Expanded(
                    child: Obx(() {
                      final data =
                          _collaborationController.tasksOfCollaboration;

                      if (data.isEmpty) {
                        return const Center(
                          child: Text(
                            "No tasks available 🚀",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: data.entries.map((entry) {
                          final projectId = entry.key;
                          final tasks = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 Project Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.folder,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Project $projectId",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${tasks.length} tasks",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // 🔹 Tasks
                                Column(
                                  children: tasks.map((depTask) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        _collaborationController.addDependency(
                                          task.id!,
                                          depTask.id ?? '',
                                        );

                                        Get.back();

                                        Get.snackbar(
                                          "Success",
                                          "Dependency added",
                                          backgroundColor: Colors.black,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.BOTTOM,
                                          borderRadius: 12,
                                          margin: const EdgeInsets.all(12),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.task_alt,
                                              size: 18,
                                              color: Colors.green,
                                            ),

                                            const SizedBox(width: 10),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    depTask.title ?? "",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    depTask.description ?? "",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const Icon(
                                              Icons.add_circle_outline,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 16),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E2A44) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF1E2A44) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          '$label $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final String deadlineText;
  final String ownerName;
  final VoidCallback? onModify;
  final VoidCallback? onUndone;
  final VoidCallback? onApprove;
  final VoidCallback? onAddDependency;

  const _TaskCard({
    required this.task,
    required this.deadlineText,
    required this.ownerName,
    this.onModify,
    this.onUndone,
    this.onApprove,
    this.onAddDependency,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = AppColors.isCompletedStatus(task.status);
    final strip = AppColors.stripColor(
      priority: task.priority,
      status: task.status,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: strip,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (isDone ? AppColors.completed : strip).withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.pending_outlined,
                    size: 16,
                    color: isDone ? AppColors.completed : strip,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor: const Color(0xFF9CA3AF),
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (onModify != null || onUndone != null)
                            PopupMenuButton<_TaskQuickAction>(
                              tooltip: 'Task actions',
                              onSelected: (action) {
                                if (action == _TaskQuickAction.modify) {
                                  onModify?.call();
                                  return;
                                }

                                if (action == _TaskQuickAction.undone) {
                                  onUndone?.call();
                                  return;
                                }

                                if (action == _TaskQuickAction.addDependency) {
                                  onAddDependency?.call(); // ✅ THIS WAS MISSING
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<_TaskQuickAction>(
                                  value: _TaskQuickAction.modify,
                                  enabled: onModify != null,
                                  child: const Text('MODIFY'),
                                ),
                                PopupMenuItem<_TaskQuickAction>(
                                  value: _TaskQuickAction.undone,
                                  enabled: onUndone != null,
                                  child: const Text('UNDONE'),
                                ),
                                PopupMenuItem<_TaskQuickAction>(
                                  value: _TaskQuickAction.addDependency,
                                  enabled: onAddDependency != null,
                                  child: const Text('Add Dependency'),
                                ),
                              ],
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF475569),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Badge(
                            text: ownerName,
                            bg: const Color(0xFFE8F5E9),
                            fg: const Color(0xFF2E7D32),
                            icon: Icons.person_rounded,
                          ),
                          _Badge(
                            text: isDone ? 'Done' : _statusLabel(task.status),
                            bg: (isDone ? AppColors.completed : strip)
                                .withValues(alpha: 0.12),
                            fg: isDone ? AppColors.completed : strip,
                          ),
                          _Badge(
                            text: deadlineText,
                            bg: const Color(0xFFFFF4E5),
                            fg: const Color(0xFFF59E0B),
                            icon: Icons.calendar_today_rounded,
                          ),
                          _Badge(
                            text: '#${task.priority}',
                            bg: const Color(0xFFEEF2FF),
                            fg: const Color(0xFF4F46E5),
                          ),
                          _Badge(
                            text: '${task.contributionPercent}% contribution',
                            bg: const Color(0xFFE8FFF2),
                            fg: const Color(0xFF119C63),
                            icon: Icons.pie_chart_outline_rounded,
                          ),
                        ],
                      ),
                      if (onApprove != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Icons.verified_rounded, size: 16),
                            label: const Text('Approve Done'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String? status) {
    final s = (status ?? '').toUpperCase();
    switch (s) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'NOT_STARTED':
      case 'TODO':
        return 'Todo';
      case 'REVIEW':
        return 'Review';
      case 'OVERDUE':
        return 'Overdue';
      case 'DONE':
      case 'COMPLETED':
        return 'Done';
      default:
        return 'Task';
    }
  }
}

enum _TaskQuickAction { modify, undone, addDependency }

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Badge({
    required this.text,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
