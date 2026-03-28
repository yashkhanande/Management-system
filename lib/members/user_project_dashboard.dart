import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/category_controller.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/controller/user_dashboard_controller.dart';
import 'package:managementt/controller/user_task_controller.dart';
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

  final UserDashboardController dc = Get.find<UserDashboardController>();
  final UserTaskController taskController = Get.find<UserTaskController>();
  final CategoryController categoryController = Get.find<CategoryController>();

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

  List<String> get _projectCategoryOptions =>
      categoryController.dropdownOptions;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    final profileController = Get.find<ProfileController>();
    final userId = profileController.member.value?.id.toString();

    if (userId != null) {
      // ignore: avoid_print
      print('UserProjectDashboard: fetching tasks for userId=$userId');
      taskController.fetchUserProjects(userId);
    } else {
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
            await dc.loadDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
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
                      const Row(
                        children: [
                          Text(
                            'My Projects',
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
                        'Overview · $formattedDate',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                      const SizedBox(height: 12),
                      _buildProjectFiltersRow(),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 44,
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => searchQuery.value = val,
                          decoration: InputDecoration(
                            hintText: 'Search projects…',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() {
                    if (dc.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final projects = taskController.userProjects;
                    final query = searchQuery.value.trim().toLowerCase();

                    var filtered = query.isEmpty
                        ? projects.toList()
                        : projects
                              .where(
                                (t) => t.title.toLowerCase().contains(query),
                              )
                              .toList();

                    if (selectedProgress.value != 'ALL') {
                      filtered = filtered.where((t) {
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
                      filtered = filtered.where((t) {
                        final priority = t.priority.trim().toUpperCase();
                        return _matchesPriority(
                          priority,
                          selectedPriority.value,
                        );
                      }).toList();
                    }

                    if (selectedCategory.value != 'ALL') {
                      filtered = filtered.where((t) {
                        final taskCategory = (t.category ?? '')
                            .trim()
                            .toLowerCase();
                        return taskCategory ==
                            selectedCategory.value.trim().toLowerCase();
                      }).toList();
                    }

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
                                'No projects found',
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
