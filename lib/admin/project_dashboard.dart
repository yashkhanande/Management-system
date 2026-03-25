import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/manage_categories_page.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/project_card.dart';
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
              hintText: 'project progress',
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
              hintText: 'project priority',
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
              hintText: 'project categories',
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
    required List<String> options,
    required String Function(String value) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 42,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        iconEnabledColor: Colors.white,
        dropdownColor: const Color(0xFF4F46E5),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(
                  labelBuilder(option),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
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
                expandedHeight: 330,
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
                      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE
                          Row(
                            children: [
                              const Text(
                                "Projects",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Spacer(),
                              InkWell(
                                onTap: () => Get.to(() => AddTask()),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const FaIcon(
                                    FontAwesomeIcons.plus,
                                    color: Colors.white,
                                    size: 16,
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
                                  label: 'Completed',
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
                          SizedBox(height: 19),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
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
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
