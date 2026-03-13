import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/task_controller.dart';
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
      body: Obx(() {
        final owned = _taskController.ownerTask;
        final projects = owned
            .where((t) => (t.type ?? '').toUpperCase() == 'PROJECT')
            .toList();
        final tasks = owned
            .where((t) => (t.type ?? '').toUpperCase() == 'TASK')
            .toList();

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
                                    color: Colors.white.withValues(alpha: 0.85),
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
                                    color: Colors.white.withValues(alpha: 0.16),
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
              title: const Text('Employee Profile'),
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
                    const Text(
                      'Projects Led',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_taskController.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (projects.isEmpty)
                      const _EmptySection(
                        text: 'No projects led by this employee',
                      )
                    else
                      ...projects.map(
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
                    const Text(
                      'Tasks Assigned (Owner)',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_taskController.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (tasks.isEmpty)
                      const _EmptySection(
                        text: 'No tasks assigned to this employee',
                      )
                    else
                      ...tasks.map(
                        (t) => _OwnedItemTile(
                          item: t,
                          deadline: _deadlineLabel(t.deadLine),
                          onTap: () {
                            final parent = _taskController.tasks
                                .firstWhereOrNull(
                                  (candidate) =>
                                      candidate.id == t.parentTaskId &&
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
