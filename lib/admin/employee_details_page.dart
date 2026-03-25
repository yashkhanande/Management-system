import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/admin/user_assignments_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/donut_chart.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/dashboard_models.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';

class EmployeeDetailsPage extends StatelessWidget {
  EmployeeDetailsPage({super.key});
  final TaskController _taskController = Get.find<TaskController>();

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final v = parts.first;
      return v.length >= 2 ? v.substring(0, 2).toUpperCase() : v.toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  int _activeProjects(List<Task> projects) {
    return projects
        .where((p) => (p.status ?? '').toUpperCase() == 'IN_PROGRESS')
        .length;
  }

  int _completedProjects(List<Task> projects) {
    return projects
        .where(
          (p) =>
              (p.status ?? '').toUpperCase() == 'DONE' ||
              (p.status ?? '').toUpperCase() == 'COMPLETED',
        )
        .length;
  }

  int _notStartedProjects(List<Task> projects) {
    return projects
        .where((p) => (p.status ?? '').toUpperCase() == 'NOT_STARTED')
        .length;
  }

  int _overdueProjects(List<Task> projects) {
    return projects
        .where((p) => (p.status ?? '').toUpperCase() == 'OVERDUE')
        .length;
  }

  int _completedTasks(List<Task> tasks) {
    return tasks
        .where(
          (t) =>
              (t.status ?? '').toUpperCase() == 'DONE' ||
              (t.status ?? '').toUpperCase() == 'COMPLETED',
        )
        .length;
  }

  int _inProgressTasks(List<Task> tasks) {
    return tasks
        .where((t) => (t.status ?? '').toUpperCase() == 'IN_PROGRESS')
        .length;
  }

  int _notStartedTasks(List<Task> tasks) {
    return tasks
        .where(
          (t) =>
              (t.status ?? '').toUpperCase() == 'NOT_STARTED' ||
              (t.status ?? '').toUpperCase() == 'TODO',
        )
        .length;
  }

  int _overdueTasks(List<Task> tasks) {
    return tasks
        .where((t) => (t.status ?? '').toUpperCase() == 'OVERDUE')
        .length;
  }

  List<StatusData> _getProjectStatusData(List<Task> projects) {
    return [
      StatusData(
        label: 'Done',
        count: _completedProjects(projects),
        color: AppColors.success,
      ),
      StatusData(
        label: 'In Progress',
        count: _activeProjects(projects),
        color: AppColors.info,
      ),
      StatusData(
        label: 'Not Started',
        count: _notStartedProjects(projects),
        color: const Color(0xFFD1D5DB),
      ),
      StatusData(
        label: 'Overdue',
        count: _overdueProjects(projects),
        color: AppColors.error,
      ),
    ];
  }

  List<StatusData> _getTaskStatusData(List<Task> tasks) {
    return [
      StatusData(
        label: 'Done',
        count: _completedTasks(tasks),
        color: AppColors.success,
      ),
      StatusData(
        label: 'In Progress',
        count: _inProgressTasks(tasks),
        color: AppColors.info,
      ),
      StatusData(
        label: 'Not Started',
        count: _notStartedTasks(tasks),
        color: const Color(0xFFD1D5DB),
      ),
      StatusData(
        label: 'Overdue',
        count: _overdueTasks(tasks),
        color: AppColors.error,
      ),
    ];
  }

  bool _isOngoing(Task item) {
    final status = (item.status ?? '').toUpperCase();
    return status != 'DONE' && status != 'COMPLETED';
  }

  bool _isCompleted(Task item) {
    final status = (item.status ?? '').toUpperCase();
    return status == 'DONE' || status == 'COMPLETED';
  }

  String _deadlineLabel(DateTime? d) {
    if (d == null) return '-';
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(now).inDays;
    if (diff < 0) return '${-diff}d overdue';
    if (diff == 0) return 'Today';
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Member member = Get.arguments;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskController.getTaskByOwner(member.id!);
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: Obx(() {
          final owned = _taskController.ownerTask;
          final projects = owned
              .where((t) => (t.type ?? '').toUpperCase() == 'PROJECT')
              .toList();
          final tasks = owned
              .where((t) => (t.type ?? '').toUpperCase() == 'TASK')
              .toList();
          final ongoingProjects = projects.where(_isOngoing).toList();
          final completedProjects = projects.where(_isCompleted).toList();
          final ongoingTasks = tasks.where(_isOngoing).toList();
          final completedTasks = tasks.where(_isCompleted).toList();
          const listLimit = 5;
          final limitedOngoingProjects = ongoingProjects
              .take(listLimit)
              .toList();
          final limitedOngoingTasks = ongoingTasks.take(listLimit).toList();
          final limitedCompletedProjects = completedProjects
              .take(listLimit)
              .toList();
          final limitedCompletedTasks = completedTasks.take(listLimit).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                _initials(member.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    member.email ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      member.role ?? 'Employee',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Total Projects',
                              value: '${projects.length}',
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricCard(
                              title: 'Active Projects',
                              value: '${_activeProjects(projects)}',
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Completed Projects',
                              value: '${_completedProjects(projects)}',
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricCard(
                              title: 'Assigned Tasks',
                              value: '${tasks.length}',
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Analytics Section
                      const Text(
                        'Analytics',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DonutChartCard(
                              title: 'Projects by Status',
                              data: _getProjectStatusData(projects),
                              total: projects.length,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DonutChartCard(
                              title: 'Tasks by Status',
                              data: _getTaskStatusData(tasks),
                              total: tasks.length,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(label: 'Name', value: member.name),
                      _InfoTile(label: 'Email', value: member.email ?? '-'),
                      _InfoTile(label: 'Role', value: member.role ?? '-'),
                      _InfoTile(label: 'Phone', value: member.mobileNo ?? '-'),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'Ongoing Projects',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (!_taskController.isLoading.value &&
                              ongoingProjects.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Get.to(
                                  () => UserAssignmentsPage(
                                    member: member,
                                    initialView: UserAssignmentsView.projects,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundColor: AppColors.primaryBlue,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('See all'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_taskController.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (ongoingProjects.isEmpty)
                        const _EmptySection(text: 'No ongoing projects')
                      else
                        ...limitedOngoingProjects.map(
                          (p) => _OwnedItemTile(
                            item: p,
                            deadline: _deadlineLabel(p.deadLine),
                            onTap: () => Get.to(
                              () => ProjectDetailPage(
                                project: p,
                                projectMemberNames: [member.name],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'Completed Projects',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (!_taskController.isLoading.value &&
                              completedProjects.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Get.to(
                                  () => UserAssignmentsPage(
                                    member: member,
                                    initialView: UserAssignmentsView.projects,
                                    initialStatusFilter: 'DONE',
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundColor: AppColors.primaryBlue,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('See all'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_taskController.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (completedProjects.isEmpty)
                        const _EmptySection(text: 'No completed projects')
                      else
                        ...limitedCompletedProjects.map(
                          (p) => _OwnedItemTile(
                            item: p,
                            deadline: _deadlineLabel(p.deadLine),
                            onTap: () => Get.to(
                              () => ProjectDetailPage(
                                project: p,
                                projectMemberNames: [member.name],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'Ongoing Tasks',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (!_taskController.isLoading.value &&
                              ongoingTasks.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Get.to(
                                  () => UserAssignmentsPage(
                                    member: member,
                                    initialView: UserAssignmentsView.tasks,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundColor: AppColors.primaryBlue,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('See all'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_taskController.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (ongoingTasks.isEmpty)
                        const _EmptySection(text: 'No ongoing tasks')
                      else
                        ...limitedOngoingTasks.map(
                          (t) => _OwnedItemTile(
                            item: t,
                            deadline: _deadlineLabel(t.deadLine),
                            onTap: () {
                              final parent = _taskController.tasks
                                  .firstWhereOrNull(
                                    (candidate) =>
                                        candidate.id == t.parentId &&
                                        (candidate.type ?? '').toUpperCase() ==
                                            'PROJECT',
                                  );
                              if (parent == null) return;
                              Get.to(
                                () => ProjectDetailPage(
                                  project: parent,
                                  projectMemberNames: [member.name],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'Completed Tasks',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (!_taskController.isLoading.value &&
                              completedTasks.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Get.to(
                                  () => UserAssignmentsPage(
                                    member: member,
                                    initialView: UserAssignmentsView.tasks,
                                    initialStatusFilter: 'DONE',
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundColor: AppColors.primaryBlue,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('See all'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_taskController.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (completedTasks.isEmpty)
                        const _EmptySection(text: 'No completed tasks')
                      else
                        ...limitedCompletedTasks.map(
                          (t) => _OwnedItemTile(
                            item: t,
                            deadline: _deadlineLabel(t.deadLine),
                            onTap: () {
                              final parent = _taskController.tasks
                                  .firstWhereOrNull(
                                    (candidate) =>
                                        candidate.id == t.parentId &&
                                        (candidate.type ?? '').toUpperCase() ==
                                            'PROJECT',
                                  );
                              if (parent == null) return;
                              Get.to(
                                () => ProjectDetailPage(
                                  project: parent,
                                  projectMemberNames: [member.name],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnedItemTile extends StatelessWidget {
  final Task item;
  final String deadline;
  final VoidCallback? onTap;

  const _OwnedItemTile({
    required this.item,
    required this.deadline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.stripColor(
      priority: item.priority,
      status: item.status,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              deadline,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String text;

  const _EmptySection({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}

class _DonutChartCard extends StatelessWidget {
  final String title;
  final List<StatusData> data;
  final int total;

  const _DonutChartCard({
    required this.title,
    required this.data,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 80,
              width: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: DonutChartPainter(data),
                  ),
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          ...data
              .where((d) => d.count > 0)
              .map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: d.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${d.label}: ${d.count}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
