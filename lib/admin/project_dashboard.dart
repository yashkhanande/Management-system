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

  String get _normalizedRole =>
      AuthController.to.role.value.trim().toUpperCase();

  String get _sessionUserId => AuthController.to.currentUserId.value.trim();

  String get _sessionUsername => AuthController.to.username.value.trim();

  bool get _isAdminSession => _normalizedRole == 'ADMIN';

  bool _canManageProject(Task project) {
    if (_isAdminSession) return true;

    final ownerId = project.ownerId.trim();
    if (ownerId.isEmpty) return false;
    final normalizedOwner = ownerId.toLowerCase();

    bool matches(String candidate) {
      final value = candidate.trim();
      if (value.isEmpty) return false;
      return value.toLowerCase() == normalizedOwner;
    }

    return matches(_sessionUserId) || matches(_sessionUsername);
  }

  List<Task> getFilteredTasks() {
    final projects = taskController.projects;
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
    switch (selected) {
      case 'Critical':
        return projectPriority == 'Critical' || projectPriority == 'HIGH';
      case 'High':
        return projectPriority == 'High';
      case 'Moderate':
        return projectPriority == 'Moderate' || projectPriority == 'MEDIUM';
      case 'Low':
        return projectPriority == 'Low' || projectPriority == 'LOW';
      case 'ALL':
      default:
        return true;
    }
  }

  Widget _buildProjectFiltersRow() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              value: selectedProgress.value,
              hintText: 'Status',
              icon: Icons.pie_chart_outline_rounded,
              options: _projectProgressOptions.keys.toList(),
              labelBuilder: (value) => _projectProgressOptions[value] ?? value,
              onChanged: (value) {
                if (value == null) return;
                _onProgressChanged(value);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterDropdown(
              value: selectedPriority.value,
              hintText: 'Priority',
              icon: Icons.flag_outlined,
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
              value: selectedCategory.value,
              hintText: 'Category',
              icon: Icons.category_outlined,
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
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required String hintText,
    required IconData icon,
    required List<String> options,
    required String Function(String value) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    final isDefault = value == 'ALL';

    return SizedBox(
      height: 46,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        menuMaxHeight: 300,
        borderRadius: BorderRadius.circular(16),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withValues(alpha: 0.95),
          size: 20,
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.74),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            icon,
            size: 16,
            color: Colors.white.withValues(alpha: isDefault ? 0.82 : 0.98),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 18,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: isDefault ? 0.13 : 0.22),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: isDefault ? 0.24 : 0.45),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white, width: 1.2),
          ),
        ),
        selectedItemBuilder: (context) {
          return options
              .map(
                (option) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option == 'ALL' ? hintText : labelBuilder(option),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList();
        },
        items: options.map((option) {
          final isSelected = option == value;
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option == 'ALL' ? 'All' : labelBuilder(option),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryDark
                    : const Color(0xFF1F2937),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

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
                expandedHeight: 290,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                    child: Padding(
                      // padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                      padding: EdgeInsets.only(
                        top: topPad + 16,
                        left: 20,
                        right: 20,
                      ),
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
                              TextButton(
                                onPressed: () =>
                                    Get.to(() => const ManageCategoriesPage()),
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
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
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
                            return Wrap(
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
                padding: const EdgeInsets.all(12),
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
                          progress: task.progress / 100,
                          timeProgress: DateTimeHelper.remainingTimeRatio(
                            task.startDate,
                            task.deadLine,
                          ),
                          teamMembers: [dc.getMemberInitials(task.ownerId)],
                          accentColor: dc.projectAccent(task),
                          onEdit: _canManageProject(task)
                              ? () {
                                  Get.to(
                                    () => AddTask(
                                      defaultType: 'PROJECT',
                                      taskToEdit: task,
                                    ),
                                  );
                                }
                              : null,
                          onTap: () {
                            Get.to(
                              () => ProjectDetailPage(
                                project: task,
                                projectMemberNames: [
                                  dc.getMemberName(task.ownerId),
                                ],
                              ),
                            );
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
