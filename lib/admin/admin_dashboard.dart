import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_dashboard.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/dashboard_tiles.dart';
import 'package:managementt/components/donut_chart.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/components/section_header.dart';
import 'package:managementt/components/stat_card.dart';
import 'package:managementt/controller/admin_nav_controller.dart';
import 'package:managementt/controller/dashboard_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DashboardController>();
    final topPad = MediaQuery.of(context).padding.top;

    // Ensure data is loaded when this page is shown.
    // If already loaded, the controller's isLoading guard prevents duplicate calls.
    if (dc.projects.isEmpty && dc.tasks.isEmpty && !dc.isLoading.value) {
      dc.loadDashboard();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        final statusData = dc.statusData;
        final criticalAlerts = dc.criticalAlerts;
        final upcomingDeadlines = dc.deadlineItems;
        final recentActivity = dc.activityItems;

        final totalStatusCount = statusData.fold<int>(
          0,
          (sum, item) => sum + item.count,
        );

        final completionPercent = dc.completionPercent;

        return SingleChildScrollView(
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
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      dc.welcomeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dc.formattedDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// STAT CARDS
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.folder_open,
                            count: '${dc.projectCount}',
                            label: 'Projects',
                            iconColor: const Color(0xFFF3B200),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            icon: Icons.edit_note,
                            count: '${dc.activeProjectCount}',
                            label: 'Active',
                            iconColor: const Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            icon: Icons.task_alt,
                            count: '${dc.totalTaskCount}',
                            label: 'Tasks',
                            iconColor: const Color(0xFF4ADE80),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            icon: Icons.warning_amber_rounded,
                            count: '${dc.overdueCount}',
                            label: 'Overdue',
                            iconColor: const Color(0xFFFACC15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// CRITICAL ALERTS
              if (criticalAlerts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: const Color(0xFFE6C3C5).withValues(alpha: 0.9),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Critical Alerts',
                                style: TextStyle(
                                  color: AppColors.alertTitle,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...criticalAlerts.map(
                            (item) => AlertTile(item: item),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              /// TASK OVERVIEW
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Task Overview",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFFF1F3FF),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(14),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color: AppColors.accent,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Analytics",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 170,
                          child: totalStatusCount > 0
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: SizedBox(
                                          height: 140,
                                          width: 140,
                                          child: CustomPaint(
                                            painter: DonutChartPainter(
                                              statusData,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: statusData
                                            .map(
                                              (item) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 9,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    item.color,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          item.label,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '${item.count}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text(
                                    'No tasks yet',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                        ),

                        const Divider(color: AppColors.divider, height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Completion',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.withValues(alpha: 0.85),
                              ),
                            ),
                            Text(
                              '$completionPercent%',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SectionHeader(
                title: 'Active Projects',
                actionText: 'See all',
                onAction: () {
                  if (Get.isRegistered<AdminNavController>()) {
                    Get.find<AdminNavController>().changePage(1);
                    return;
                  }
                  Get.to(() => ProjectDashboard());
                },
              ),

              ...List.generate(dc.projects.take(5).length, (i) {
                final project = dc.projects[i];
                final totalSub = project.completedTask + project.remainingTask;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ProjectCard(
                    title: project.title,
                    subtitle: project.description,
                    dueText: dc.formatDeadline(project.deadLine),
                    status: '${project.completedTask}/$totalSub tasks',
                    progress: project.progress / 100.0,
                    teamMembers: [dc.getMemberInitials(project.ownerId)],
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
                  ),
                );
              }),

              const SizedBox(height: 10),

              const SectionHeader(title: 'Upcoming Deadlines'),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.9),
                    ),
                  ),
                  child: upcomingDeadlines.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text(
                            'No upcoming deadlines',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : Column(
                          children: upcomingDeadlines
                              .map((item) => DeadlineTile(item: item))
                              .toList(),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              const SectionHeader(title: 'Activity Log'),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.9),
                    ),
                  ),
                  child: recentActivity.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text(
                            'No team activity yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : Column(
                          children: recentActivity
                              .map((item) => ActivityTile(item: item))
                              .toList(),
                        ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }
}
