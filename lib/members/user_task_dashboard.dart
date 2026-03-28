import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/controller/user_task_controller.dart';
import 'package:managementt/model/filter_enums.dart';
import 'package:managementt/controller/user_dashboard_controller.dart';
import 'package:managementt/members/user_task_detail_page.dart';
import 'package:managementt/service/task_service.dart';

const _months = [
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

class UserTaskDashboard extends StatefulWidget {
  const UserTaskDashboard({super.key});

  @override
  State<UserTaskDashboard> createState() => _UserTaskDashboardState();
}

class _UserTaskDashboardState extends State<UserTaskDashboard> {
  late TextEditingController searchController;
  final searchQuery = ''.obs;
  final statusFilter = TaskStatusFilter.all.obs;
  final priorityFilter = PriorityFilter.all.obs;
  final UserTaskController taskController = Get.find<UserTaskController>();

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    final profileController = Get.find<ProfileController>();
    final userId = profileController.member.value?.id.toString();

    if (userId != null) {
      // fetch immediately if id already available
      // debug log to help diagnose missing projects
      // ignore: avoid_print
      print('UserProjectDashboard: fetching tasks for userId=$userId');
      taskController.fetchUserTasks(userId);
    } else {
      // listen once and fetch when the id becomes available
      once(profileController.member, (val) {
        final newId = val?.id.toString();
        // ignore: avoid_print
        print(
          'UserProjectDashboard: detected userId update, fetching for $newId',
        );
        if (newId != null) taskController.fetchUserTasks(newId);
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final dc = Get.find<UserDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: RefreshIndicator(
          onRefresh: () async {
            await TaskService().checkOverdue();
            await dc.loadDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(26),
                      bottomRight: Radius.circular(26),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      const Text(
                        "My Tasks",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Overview · $formattedDate",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// STAT CHIPS
                      Obx(() {
                        final tasks = taskController.userTasks;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              label: 'Total',
                              count: tasks.length,
                              color: const Color(0xFF60A5FA),
                            ),
                            _StatChip(
                              label: 'Active',
                              count: tasks
                                  .where((t) => t.status == 'IN_PROGRESS')
                                  .length,
                              color: const Color(0xFF4ADE80),
                            ),
                            _StatChip(
                              label: 'Done',
                              count: tasks
                                  .where((t) => t.status == 'DONE')
                                  .length,
                              color: const Color(0xFFA78BFA),
                            ),
                            _StatChip(
                              label: 'Overdue',
                              count: tasks
                                  .where((t) => t.status == 'OVERDUE')
                                  .length,
                              color: const Color(0xFFF87171),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 14),

                      /// SEARCH
                      SizedBox(
                        height: 44,
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => searchQuery.value = val,
                          decoration: InputDecoration(
                            hintText: "Search tasks…",
                            hintStyle: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.12),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// STATUS FILTERS
                      Obx(() {
                        final selected = statusFilter.value;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                isSelected: selected == TaskStatusFilter.all,
                                onTap: () =>
                                    statusFilter.value = TaskStatusFilter.all,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Todo',
                                isSelected: selected == TaskStatusFilter.todo,
                                onTap: () =>
                                    statusFilter.value = TaskStatusFilter.todo,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'In Progress',
                                isSelected:
                                    selected == TaskStatusFilter.inProgress,
                                onTap: () => statusFilter.value =
                                    TaskStatusFilter.inProgress,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Under Review',
                                isSelected:
                                    selected == TaskStatusFilter.underReview,
                                onTap: () => statusFilter.value =
                                    TaskStatusFilter.underReview,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Done',
                                isSelected: selected == TaskStatusFilter.done,
                                onTap: () =>
                                    statusFilter.value = TaskStatusFilter.done,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Overdue',
                                isSelected:
                                    selected == TaskStatusFilter.overdue,
                                onTap: () => statusFilter.value =
                                    TaskStatusFilter.overdue,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// TASK LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() {
                    if (dc.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    var filtered = taskController.userTasks.toList();

                    // Apply status filter
                    if (statusFilter.value != TaskStatusFilter.all) {
                      filtered = filtered.where((task) {
                        final status = (task.status ?? '').toUpperCase();
                        switch (statusFilter.value) {
                          case TaskStatusFilter.todo:
                            return status == 'NOT_STARTED' || status == 'TODO';
                          case TaskStatusFilter.inProgress:
                            return status == 'IN_PROGRESS';
                          case TaskStatusFilter.underReview:
                            return status == 'REVIEW';
                          case TaskStatusFilter.done:
                            return status == 'DONE' || status == 'COMPLETED';
                          case TaskStatusFilter.overdue:
                            return status == 'OVERDUE';
                          default:
                            return true;
                        }
                      }).toList();
                    }

                    // Apply search query
                    final query = searchQuery.value.trim().toLowerCase();
                    if (query.isNotEmpty) {
                      filtered = filtered
                          .where((t) => t.title.toLowerCase().contains(query))
                          .toList();
                    }

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No tasks found",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
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
                          child: InkWell(
                            onTap: () {
                              Get.to(() => UserTaskDetailPage(task: task));
                            },
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
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color:
                                              (isDone
                                                      ? AppColors.completed
                                                      : strip)
                                                  .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isDone
                                              ? Icons.check
                                              : Icons.pending_outlined,
                                          size: 16,
                                          color: isDone
                                              ? AppColors.completed
                                              : strip,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
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
                                                decorationColor: const Color(
                                                  0xFF9CA3AF,
                                                ),
                                                decorationThickness: 2,
                                              ),
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
                                                  text: isDone
                                                      ? 'Done'
                                                      : _statusLabel(
                                                          task.status,
                                                        ),
                                                  bg:
                                                      (isDone
                                                              ? AppColors
                                                                    .completed
                                                              : strip)
                                                          .withValues(
                                                            alpha: 0.12,
                                                          ),
                                                  fg: isDone
                                                      ? AppColors.completed
                                                      : strip,
                                                ),
                                                _Badge(
                                                  text: dc.formatDeadline(
                                                    task.deadLine,
                                                  ),
                                                  bg: const Color(0xFFFFF4E5),
                                                  fg: const Color(0xFFF59E0B),
                                                  icon: Icons
                                                      .calendar_today_rounded,
                                                ),
                                                _Badge(
                                                  text: '#${task.priority}',
                                                  bg: const Color(0xFFEEF2FF),
                                                  fg: const Color(0xFF4F46E5),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
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

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4338CA) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

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
