import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/profile_controller.dart';
// ...existing code...
import 'package:managementt/controller/user_dashboard_controller.dart';
import 'package:managementt/controller/user_task_controller.dart';
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

class UserProjectDashboard extends StatefulWidget {
  const UserProjectDashboard({super.key});

  @override
  State<UserProjectDashboard> createState() => _UserProjectDashboardState();
}

class _UserProjectDashboardState extends State<UserProjectDashboard> {
  late TextEditingController searchController;
  final searchQuery = ''.obs;

  final selectedProgress = 'ALL'.obs;
  final selectedPriority = 'ALL'.obs;
  final selectedCategory = 'ALL'.obs;

  static const Map<String, String> _projectProgressOptions = {
    'ALL': 'ALL',
    'IN_PROGRESS': 'In progress',
    'DONE': 'Done',
    'NOT_STARTED': 'Not started',
    'OVERDUE': 'Overdue',
  };

  static const List<String> _projectPriorityOptions = [
    'ALL',
    'Critical',
    'High',
    'Moderate',
    'Low',
  ];

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
      taskController.fetchUserProjects(userId);
    } else {
      // listen once and fetch when the id becomes available
      once(profileController.member, (val) {
        final newId = val?.id.toString();
        // ignore: avoid_print
        print(
          'UserProjectDashboard: detected userId update, fetching for $newId',
        );
        if (newId != null) taskController.fetchUserProjects(newId);
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

  final dc = Get.find<UserDashboardController>();
  final taskController = Get.find<UserTaskController>();

  List<String> get _projectCategoryOptions {
    final categories = <String>{};
    for (final project in taskController.userProjects) {
      final category = (project.category ?? '').trim();
      if (category.isNotEmpty) categories.add(category);
    }
    return ['ALL', ...categories];
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
        return 'In progress';
      case 'NOT_STARTED':
      case 'TODO':
        return 'Not started';
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

  List<Task> getFilteredProjects() {
    final projects = taskController.userProjects;
    final query = searchQuery.value.trim().toLowerCase();

    var filtered = projects.where((t) {
      if (query.isEmpty) return true;
      return t.title.toLowerCase().contains(query);
    }).toList();

    if (selectedProgress.value != 'ALL') {
      filtered = filtered.where((t) {
        final status = (t.status ?? '').toUpperCase();
        switch (selectedProgress.value) {
          case 'IN_PROGRESS':
            return status == 'IN_PROGRESS';
          case 'DONE':
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
      filtered = filtered.where((t) {
        final priority = t.priority.trim().toUpperCase();
        return _matchesPriority(priority, selectedPriority.value);
      }).toList();
    }

    if (selectedCategory.value != 'ALL') {
      filtered = filtered.where((t) {
        final taskCategory = (t.category ?? '').trim().toLowerCase();
        return taskCategory == selectedCategory.value.trim().toLowerCase();
      }).toList();
    }

    return filtered;
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
                      colors: [AppColors.primary, AppColors.alertTitle],
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
                      /// TITLE ROW
                      Row(
                        children: [
                          const Text(
                            "My Projects",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                          children: [
                            _StatChip(
                              label: 'Total',
                              count: taskController.userProjects.length,
                              color: const Color(0xFF60A5FA),
                            ),
                            _StatChip(
                              label: 'Active',
                              count: taskController.userProjects
                                  .where((t) => t.status == 'IN_PROGRESS')
                                  .length,
                              color: const Color(0xFF4ADE80),
                            ),
                            _StatChip(
                              label: 'Done',
                              count: taskController.userProjects
                                  .where((t) => t.status == 'DONE')
                                  .length,
                              color: const Color(0xFFA78BFA),
                            ),
                            _StatChip(
                              label: 'Overdue',
                              count: taskController.userProjects
                                  .where((t) => t.status == 'OVERDUE')
                                  .length,
                              color: const Color(0xFFF87171),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 14),

                      _buildProjectFiltersRow(),

                      const SizedBox(height: 14),

                      /// SEARCH
                      SizedBox(
                        height: 44,
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => searchQuery.value = val,
                          decoration: InputDecoration(
                            hintText: "Search projects…",
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
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// PROJECT LIST using ProjectCard
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() {
                    if (dc.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final filtered = getFilteredProjects();

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No projects found",
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
                        final project = filtered[index];
                        final totalSub =
                            project.completedTask + project.remainingTask;
                        final ownerInitials = dc.getMemberInitials(
                          project.ownerId,
                        );

                        return ProjectCard(
                          title: project.title,
                          subtitle: project.description,
                          dueText: dc.formatDeadline(project.deadLine),
                          status: totalSub > 0
                              ? '${project.completedTask}/$totalSub tasks'
                              : null,
                          priority: _priorityLabel(project.priority),
                          state: _statusLabel(project.status),
                          progress: project.progress / 100.0,
                          timeProgress: DateTimeHelper.remainingTimeRatio(
                            project.startDate,
                            project.deadLine,
                          ),
                          teamMembers: [ownerInitials],
                          accentColor: dc.projectAccent(project),
                          onTap: () {
                            Get.to(
                              () => ProjectDetailPage(
                                project: project,
                                projectMemberNames: [
                                  dc.getMemberName(project.ownerId),
                                ],
                              ),
                            );
                          },
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
