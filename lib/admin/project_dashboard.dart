import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/manage_categories_page.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/category_controller.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';
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

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({super.key});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  final TaskController taskController = Get.find<TaskController>();
  final DashboardController dc = Get.find<DashboardController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  final selectedProgress = 'ALL'.obs;
  final selectedPriority = 'ALL'.obs;
  final selectedCategory = 'ALL'.obs;

  static const Map<String, String> _projectProgressOptions = {
    'ALL': 'ALL',
    'IN_PROGRESS': 'IN PROGRESS',
    'COMPLETED': 'COMPLETED',
    'NOT_STARTED': 'NOT STARTED',
    'OVERDUE': 'OVERDUE',
  };
  static const List<String> _projectPriorityOptions = [
    'ALL',
    'Critical',
    'High',
    'Moderate',
    'Low',
  ];
  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  List<String> get _projectCategoryOptions =>
      categoryController.dropdownOptions;

  List<Task> getFilteredTasks() {
    final projects = taskController.projects.toList(growable: false);
    final searchQuery = taskController.searchQuery.value.trim().toLowerCase();

    var allTasks = projects.where((t) {
      if (searchQuery.isEmpty) return true;
      final title = t.title.toLowerCase();
      final ownerName = dc.getMemberName(t.ownerId).toLowerCase();
      return title.contains(searchQuery) || ownerName.contains(searchQuery);
    }).toList();

    if (selectedProgress.value != 'ALL') {
      allTasks = allTasks.where((t) {
        final status = (t.status ?? '').toUpperCase();
        switch (selectedProgress.value) {
          case 'IN_PROGRESS':
            return status == 'IN_PROGRESS';
          case 'COMPLETED':
            return status == 'DONE' || status == 'COMPLETED';
          case 'NOT_STARTED':
            return status == 'NOT_STARTED' || status == 'TODO';
          case 'OVERDUE':
            return status == 'OVERDUE';
          case 'ALL':
          default:
            return true;
        }
      }).toList();
    }

    if (selectedPriority.value != 'ALL') {
      allTasks = allTasks.where((t) {
        final priority = t.priority.trim().toUpperCase();
        return _matchesPriority(priority, selectedPriority.value);
      }).toList();
    }

    if (selectedCategory.value != 'ALL') {
      allTasks = allTasks.where((t) {
        final taskCategory = (t.category ?? '').trim().toLowerCase();
        return taskCategory == selectedCategory.value.trim().toLowerCase();
      }).toList();
    }

    return allTasks;
  }

  void _onProgressChanged(String value) {
    selectedProgress.value = value;
    if (value != 'ALL') {
      selectedPriority.value = 'ALL';
      selectedCategory.value = 'ALL';
    }
  }

  void _onPriorityChanged(String value) {
    selectedPriority.value = value;
    if (value != 'ALL') {
      selectedProgress.value = 'ALL';
      selectedCategory.value = 'ALL';
    }
  }

  void _onCategoryChanged(String value) {
    selectedCategory.value = value;
    if (value != 'ALL') {
      selectedProgress.value = 'ALL';
      selectedPriority.value = 'ALL';
    }
  }

  bool _matchesPriority(String projectPriority, String selected) {
    final p = projectPriority.trim().toUpperCase();
    switch (selected.trim().toUpperCase()) {
      case 'CRITICAL':
        return p == 'CRITICAL';
      case 'HIGH':
        return p == 'HIGH';
      case 'MODERATE':
      case 'MEDIUM':
        return p == 'MODERATE' || p == 'MEDIUM';
      case 'LOW':
        return p == 'LOW';
      case 'ALL':
      default:
        return true;
    }
  }

  String _statusLabel(String? status) {
    final s = (status ?? '').trim().toUpperCase();
    switch (s) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'NOT_STARTED':
      case 'TODO':
        return 'Todo';
      case 'OVERDUE':
        return 'Overdue';
      case 'DONE':
      case 'COMPLETED':
        return 'Done';
      default:
        return 'Planned';
    }
  }

  String _priorityLabel(String raw) {
    final p = raw.trim();
    if (p.isEmpty) return 'N/A';
    final up = p.toUpperCase();
    switch (up) {
      case 'CRITICAL':
        return 'Critical';
      case 'HIGH':
        return 'High';
      case 'MODERATE':
      case 'MEDIUM':
        return 'Moderate';
      case 'LOW':
        return 'Low';
      default:
        return p;
    }
  }

  Widget _buildProjectFiltersRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Progress',
                  value: selectedProgress.value,
                  hintText: 'Select progress',
                  options: _projectProgressOptions.keys.toList(),
                  labelBuilder: (value) =>
                      _projectProgressOptions[value] ?? value,
                  onChanged: (value) {
                    if (value == null) return;
                    _onProgressChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Priority',
                  value: selectedPriority.value,
                  hintText: 'Select priority',
                  options: _projectPriorityOptions,
                  labelBuilder: (value) => value,
                  onChanged: (value) {
                    if (value == null) return;
                    _onPriorityChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Category',
                  value: selectedCategory.value,
                  hintText: 'Select category',
                  options: _projectCategoryOptions,
                  labelBuilder: (value) => value,
                  onChanged: (value) {
                    if (value == null) return;
                    _onCategoryChanged(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required String hintText,
    required List<String> options,
    required String Function(String value) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cappedMenuWidth = (constraints.maxWidth - 16)
            .clamp(0.0, constraints.maxWidth)
            .toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbVisibility: WidgetStateProperty.all(false),
                    trackVisibility: WidgetStateProperty.all(false),
                    thickness: WidgetStateProperty.all(0),
                    radius: const Radius.circular(0),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: value,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  dropdownColor: AppColors.alertTitle,
                  borderRadius: BorderRadius.circular(12),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  menuMaxHeight: 240,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.14),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.7),
                        width: 1.15,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white, width: 1.35),
                    ),
                  ),
                  items: options
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: cappedMenuWidth,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    labelBuilder(option),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomNavSpace = MediaQuery.of(context).padding.bottom + 80;
    final headerHeight = topPad + 222;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: RefreshIndicator(
          onRefresh: () async {
            await TaskService().checkOverdue();
            await taskController.getAllTask();
          },
          child: CustomScrollView(
            slivers: [
              /// HEADER
              SliverAppBar(
                pinned: true,
                expandedHeight: headerHeight,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.alertTitle],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Projects",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Get.to(
                                    () => const ManageCategoriesPage(),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    minimumSize: const Size(0, 28),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Manage Project Categories',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Text(
                            "Overview · $formattedDate",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),

                          /// STATS
                          Obx(() {
                            final tasks = taskController.projects;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatChip(
                                  label: 'Total',
                                  count: tasks.length,
                                  color: Colors.blue,
                                ),
                                _StatChip(
                                  label: 'Active',
                                  count: tasks
                                      .where((t) => t.status == 'IN_PROGRESS')
                                      .length,
                                  color: Colors.green,
                                ),
                                _StatChip(
                                  label: 'Done',
                                  count: tasks
                                      .where((t) => t.status == 'DONE')
                                      .length,
                                  color: Colors.purple,
                                ),
                                _StatChip(
                                  label: 'Overdue',
                                  count: tasks
                                      .where((t) => t.status == 'OVERDUE')
                                      .length,
                                  color: Colors.red,
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 10),

                          _buildProjectFiltersRow(),

                          const SizedBox(height: 10),

                          /// SEARCH
                          SizedBox(
                            height: 44,
                            child: TextField(
                              onChanged: (val) =>
                                  taskController.searchQuery.value = val,
                              decoration: InputDecoration(
                                hintText: "Search...",
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// LIST
              SliverPadding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, bottomNavSpace),
                sliver: Obx(() {
                  final tasks = getFilteredTasks();
                  final _ = taskController.searchQuery.value;

                  if (tasks.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text("No projects found")),
                    );
                  }

                  return SliverList.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final total = task.completedTask + task.remainingTask;

                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return AppConfirmDialog.show(
                            title: 'Delete Project',
                            message: 'Remove "${task.title}"?',
                            confirmText: 'Delete',
                          );
                        },
                        onDismissed: (_) {
                          if (task.id != null) {
                            taskController.removeTask(task.id!);
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ProjectCard(
                          title: task.title,
                          subtitle: task.description,
                          dueText: dc.formatDeadline(task.deadLine),
                          status: total > 0
                              ? '${task.completedTask}/$total'
                              : null,
                          priority: _priorityLabel(task.priority),
                          state: _statusLabel(task.status),
                          progress: task.progress / 100,
                          timeProgress: DateTimeHelper.remainingTimeRatio(
                            task.startDate,
                            task.deadLine,
                          ),
                          teamMembers: [dc.getMemberInitials(task.ownerId)],
                          accentColor: dc.projectAccent(task),
                          // onEdit: _canManageProject(task)
                          //     ? () {
                          //         Get.to(
                          //           () => AddTask(
                          //             defaultType: 'PROJECT',
                          //             taskToEdit: task,
                          //           ),
                          //         );
                          //       }
                          //     : null,
                          onTap: () async {
                            final changed = await Get.to<bool>(
                              () => ProjectDetailPage(
                                project: task,
                                projectMemberNames: [
                                  dc.getMemberName(task.ownerId),
                                ],
                              ),
                            );
                            if (changed == true) {
                              await taskController.getAllTask();
                            }
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
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
      margin: EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
