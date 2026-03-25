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
                              label: 'Completed',
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

                    final projects = taskController.userProjects;

                    final query = searchQuery.value.trim().toLowerCase();
                    final filtered = query.isEmpty
                        ? projects
                        : projects
                              .where(
                                (t) => t.title.toLowerCase().contains(query),
                              )
                              .toList();

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
