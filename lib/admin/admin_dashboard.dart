import 'package:flutter/material.dart';
import 'package:managementt/components/animated_gradient_container.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/dashboard_bottom_nav.dart';
import 'package:managementt/components/dashboard_tiles.dart';
import 'package:managementt/components/donut_chart.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/components/section_header.dart';
import 'package:managementt/components/stat_card.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/dashboard_models.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _refreshDashboard(BuildContext context) async {
    final controller = TaskController();
    await controller.getAllTask();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dashboard refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    final statusData = <StatusData>[
      const StatusData(label: 'Done', count: 5, color: AppColors.success),
      const StatusData(label: 'In Progress', count: 7, color: AppColors.info),
      const StatusData(label: 'Review', count: 2, color: AppColors.warning),
      const StatusData(label: 'Todo', count: 3, color: Color(0xFFD1D5DB)),
    ];

    final criticalAlerts = <AlertItem>[
      const AlertItem(
        title: 'HR Management System',
        subtitle: '174 past deadline',
      ),
      const AlertItem(
        title: '8 tasks overdue',
        subtitle: 'Tap to view and resolve',
      ),
    ];

    final upcomingDeadlines = <DeadlineItem>[
      const DeadlineItem(
        title: 'Payroll Integration',
        subtitle: 'HR Management System',
        due: '434d ago',
        accent: AppColors.error,
        initials: 'PP',
      ),
      const DeadlineItem(
        title: 'Reporting Dashboard',
        subtitle: 'HR Management System',
        due: '334d ago',
        accent: AppColors.warning,
        initials: 'AK',
      ),
      const DeadlineItem(
        title: 'User Acceptance Testing',
        subtitle: 'HR Management System',
        due: '174d ago',
        accent: AppColors.error,
        initials: 'TW',
      ),
      const DeadlineItem(
        title: 'Checkout Flow Optimization',
        subtitle: 'E-Commerce Platform Redesign',
        due: '154d ago',
        accent: AppColors.warning,
        initials: 'SC',
      ),
      const DeadlineItem(
        title: 'Performance Optimization',
        subtitle: 'E-Commerce Platform Redesign',
        due: '124d ago',
        accent: AppColors.warning,
        initials: 'AK',
      ),
    ];

    final recentActivity = <ActivityItem>[
      const ActivityItem(
        initials: 'AK',
        message: 'Alex submitted "Performance Optimization" for review',
        project: 'E-Commerce Platform Redesign',
        when: '15 day ago',
      ),
      const ActivityItem(
        initials: 'PP',
        message: 'Priya completed "Authentication Module"',
        project: 'Mobile Banking App v2',
        when: '1 month ago',
      ),
      const ActivityItem(
        initials: 'JP',
        message: 'Project "AI Analytics Dashboard" created',
        project: 'DataViz Ltd.',
        when: '1 month ago',
      ),
      const ActivityItem(
        initials: 'MJ',
        message: 'Marcus started "Transaction History UI"',
        project: 'Mobile Banking App v2',
        when: '1 month ago',
      ),
      const ActivityItem(
        initials: 'PP',
        message: 'Priya submitted "Payroll Integration" for review',
        project: 'HR Management System',
        when: '2 months ago',
      ),
    ];

    final totalStatusCount = statusData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    final completionPercent =
        ((statusData.first.count / totalStatusCount) * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: AppColors.primary),

      bottomNavigationBar: const DashboardBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AnimatedGradientContainer(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      "Manthan Agrawal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      "Sunday, 22 Jan 2026",
                      style: TextStyle(color: Colors.white),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.folder_open,
                            count: '4',
                            label: 'Projects',
                            iconColor: const Color(0xFFF3B200),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.edit_note,
                            count: '4',
                            label: 'Active',
                            iconColor: const Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.task_alt,
                            count: '14',
                            label: 'Tasks',
                            iconColor: const Color(0xFF4ADE80),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.warning_amber_rounded,
                            count: '8',
                            label: 'Overdue',
                            iconColor: const Color(0xFFFACC15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
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
                        ...criticalAlerts.map((item) => AlertTile(item: item)),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 2),
              //Task overview
              Padding(
                padding: EdgeInsets.all(20),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: CustomPaint(
                                      painter: DonutChartPainter(statusData),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: statusData
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 9,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: item.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
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
                                                  fontWeight: FontWeight.w600,
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
              const SectionHeader(
                title: 'Active Projects',
                actionText: 'See all',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "E-Commerce Platform Redesign",
                  subtitle: 'ShopNow Inc.',
                  dueText: '9d over',
                  status: '2/5 tasks',
                  progress: 0.78,
                  teamMembers: ['SC', 'TW', 'MJ', 'AK'],
                  accentColor: AppColors.projectBlue,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "Mobile Banking App v2",
                  subtitle: 'TrustBank Corp.',
                  dueText: '36d left',
                  status: '1/3 tasks',
                  progress: 0.35,
                  teamMembers: ['SC', 'JP', 'PP', 'TW'],
                  accentColor: AppColors.projectTeal,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "HR Management System",
                  subtitle: 'Internal',
                  dueText: '174d over',
                  status: '2/5 tasks',
                  progress: 0.92,
                  teamMembers: ['PP', 'TW', 'SC', 'AK'],
                  accentColor: AppColors.projectPink,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "AI Analytics Dashboard",
                  subtitle: 'DataViz Ltd.',
                  dueText: '66d left',
                  status: '0/4 tasks',
                  progress: 0.08,
                  teamMembers: ['SC', 'PP'],
                  accentColor: AppColors.projectPurple,
                ),
              ),

              const SectionHeader(
                title: 'Upcoming Deadlines',
                actionText: 'See all',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: upcomingDeadlines
                        .map((item) => DeadlineTile(item: item))
                        .toList(),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: SectionHeader(title: 'Team', actionText: 'See all'),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: SectionHeader(
                  title: 'Recent Activity',
                  trailing: TextButton.icon(
                    onPressed: () => _refreshDashboard(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      Icons.refresh,
                      size: 14,
                      color: Colors.blueGrey.withValues(alpha: 0.85),
                    ),
                    label: Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.blueGrey.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 86),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: recentActivity
                          .map((item) => ActivityTile(item: item))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
