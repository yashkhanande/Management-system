import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/pagination_loading_indicator.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/controller/project_pagination_controller.dart';
import 'package:managementt/model/filter_enums.dart';
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
  late ProjectPaginationController paginationController;
  final TaskController taskController = Get.find<TaskController>();
  final DashboardController dc = Get.find<DashboardController>();
  static const List<_StatusFilterChipData> _statusFilterOptions = [
    _StatusFilterChipData(
      filter: ProjectStatusFilter.all,
      label: 'All',
      color: Color.fromARGB(255, 203, 188, 230),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.active,
      label: 'In Progress',
      color: Color(0xFF2563EB),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.completed,
      label: 'Completed',
      color: Color(0xFF14B8A6),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.notStarted,
      label: 'Not Started',
      color: Color.fromARGB(255, 249, 188, 22),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.overdue,
      label: 'Overdue',
      color: Color(0xFFF97316),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final alreadyRegistered = Get.isRegistered<ProjectPaginationController>();
    paginationController = alreadyRegistered
        ? Get.find<ProjectPaginationController>()
        : Get.put(ProjectPaginationController());
    paginationController.updateStatusFilter(ProjectStatusFilter.all);
    paginationController.updatePriorityFilter(PriorityFilter.all);
    paginationController.updateSearchQuery('');

    // Only trigger a manual refresh when reusing an existing controller.
    // Newly created controllers automatically load their first page in onInit.
    if (alreadyRegistered) {
      paginationController.resetPagination();
      paginationController.loadNextPage();
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ProjectPaginationController>()) {
      Get.delete<ProjectPaginationController>();
    }
    super.dispose();
  }

  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildStatusFilterCarousel() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final selectedFilter = paginationController.statusFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _statusFilterOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final option = _statusFilterOptions[index];
            final count = _projectCountFor(option.filter);
            return _StatusFilterChip(
              data: option,
              isActive: option.filter == selectedFilter,
              count: count,
              onTap: () =>
                  paginationController.updateStatusFilter(option.filter),
            );
          },
        );
      }),
    );
  }

  int _projectCountFor(ProjectStatusFilter filter) {
    final projects = paginationController.items;
    if (filter == ProjectStatusFilter.all) {
      return projects.length;
    }

    return projects.where((project) {
      final status = ((project.status) ?? '').toUpperCase();
      switch (filter) {
        case ProjectStatusFilter.active:
          return status == 'IN_PROGRESS';
        case ProjectStatusFilter.completed:
          return status == 'DONE' || status == 'COMPLETED';
        case ProjectStatusFilter.overdue:
          return status == 'OVERDUE';
        case ProjectStatusFilter.notStarted:
          return status == 'NOT_STARTED';
        case ProjectStatusFilter.all:
          return true;
      }
    }).length;
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
            paginationController.resetPagination();
            await paginationController.loadNextPage();
          },
          child: CustomScrollView(
            controller: paginationController.scrollController,
            slivers: [
              /// HEADER
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 330,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// TITLE ROW
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
                              fontSize: 13,
                            ),
                          ),

                          /// STAT CHIPS
                          Obx(() {
                            final projects = paginationController.items;
                            final completedCount = dc.completedProjectCount;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StatChip(
                                  label: 'Total',
                                  count: projects.length,
                                  color: const Color(0xFF60A5FA),
                                ),
                                _StatChip(
                                  label: 'Active',
                                  count: projects
                                      .where((t) => t.status == 'IN_PROGRESS')
                                      .length,
                                  color: const Color(0xFF4ADE80),
                                ),
                                _StatChip(
                                  label: 'Completed',
                                  count: completedCount,
                                  color: const Color(0xFFA78BFA),
                                ),
                                _StatChip(
                                  label: 'Overdue',
                                  count: projects
                                      .where((t) => t.status == 'OVERDUE')
                                      .length,
                                  color: const Color(0xFFF87171),
                                ),
                              ],
                            );
                          }),

                          /// STATUS FILTERS
                          _buildStatusFilterCarousel(),

                          /// SEARCH
                          SizedBox(
                            height: 44,
                            child: TextField(
                              onChanged: (val) =>
                                  paginationController.updateSearchQuery(val),
                              decoration: InputDecoration(
                                hintText: "Search by project name or owner…",
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
                  ),
                ),
              ),

              /// PROJECT LIST
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                sliver: Obx(() {
                  final state = paginationController.paginationState.value;
                  final filteredProjects = paginationController
                      .getFilteredItems((ownerId) => dc.getMemberName(ownerId));

                  if (filteredProjects.isEmpty &&
                      !state.isLoading &&
                      state.error == null) {
                    return SliverToBoxAdapter(
                      child: Padding(
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
                      ),
                    );
                  }

                  if (filteredProjects.isEmpty && state.isLoading) {
                    return SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  return SliverList.builder(
                    itemCount: filteredProjects.length + 2,
                    itemBuilder: (context, index) {
                      // Show loading indicator at bottom
                      if (index == filteredProjects.length) {
                        return PaginationLoadingIndicator(
                          isLoading: state.isLoading,
                        );
                      }

                      // Show end-of-list indicator
                      if (index == filteredProjects.length + 1) {
                        return EndOfListIndicator(
                          show: !state.hasMore && !state.isLoading,
                        );
                      }

                      final task = filteredProjects[index];
                      final totalSub = task.completedTask + task.remainingTask;
                      final ownerInitials = dc.getMemberInitials(task.ownerId);

                      return Dismissible(
                        key: ValueKey(task.id ?? index),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return AppConfirmDialog.show(
                            title: 'Delete Project',
                            message:
                                'Remove "${task.title}" and all its tasks?',
                            cancelText: 'Cancel',
                            confirmText: 'Delete',
                            tone: AppDialogTone.danger,
                            icon: Icons.delete_outline_rounded,
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
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        child: ProjectCard(
                          title: task.title,
                          subtitle: task.description,
                          dueText: dc.formatDeadline(task.deadLine),
                          status: totalSub > 0
                              ? '${task.completedTask}/$totalSub tasks'
                              : null,
                          progress: task.progress / 100.0,
                          timeProgress: DateTimeHelper.remainingTimeRatio(
                            task.startDate,
                            task.deadLine,
                          ),
                          teamMembers: [ownerInitials],
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

class _StatusFilterChipData {
  final ProjectStatusFilter filter;
  final String label;
  final Color color;

  const _StatusFilterChipData({
    required this.filter,
    required this.label,
    required this.color,
  });
}

class _StatusFilterChip extends StatelessWidget {
  final _StatusFilterChipData data;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.data,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? data.color.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? data.color : Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Text(
          data.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
