import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/controller/admin_nav_controller.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/profile_controller.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage>
    with SingleTickerProviderStateMixin {
  bool _showProjects = false;

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    final ac = Get.find<AuthController>();
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        final tasks = pc.memberTasks.map((t) {
          final isCompleted = t.status == 'DONE';
          Color statusColor;
          String statusLabel;
          String dueText;

          switch (t.status) {
            case 'DONE':
              statusColor = const Color(0xFF22C55E);
              statusLabel = 'Done';
              break;
            case 'TODO':
              statusColor = const Color(0xFF3B82F6);
              statusLabel = 'In Progress';
              break;
            case 'OVERDUE':
              statusColor = const Color(0xFFEF4444);
              statusLabel = 'Overdue';
              break;
            default:
              statusColor = const Color(0xFF9CA3AF);
              statusLabel = 'To Do';
          }

          if (t.deadLine != null) {
            final diff = t.deadLine!
                .difference(
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  ),
                )
                .inDays;
            if (diff < 0) {
              dueText = '${-diff}d overdue';
            } else if (diff == 0) {
              dueText = 'Today';
            } else {
              dueText = '${t.deadLine!.month}/${t.deadLine!.day}';
            }
          } else {
            dueText = '';
          }

          return _TaskItem(
            title: t.title,
            project: t.description,
            status: statusLabel,
            due: dueText,
            accent: const Color(0xFFE91E63),
            statusColor: statusColor,
            isCompleted: isCompleted,
          );
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              // ─── Header ───
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6D70F6), Color(0xFF8986F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + settings row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final nav = Get.find<AdminNavController>();
                            nav.changePage(0);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ac.logout();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Avatar + name row
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              pc.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pc.memberName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pc.memberRole,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  pc.memberRole,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Stat pills
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            count: '${pc.totalTasks}',
                            label: 'Total',
                            icon: Icons.assignment_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            count: '${pc.activeTasks}',
                            label: 'Active',
                            icon: Icons.play_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            count: '${pc.doneTasks}',
                            label: 'Done',
                            icon: Icons.task_alt_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            count: '${pc.overdueTasks}',
                            label: 'Overdue',
                            icon: Icons.warning_amber_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ─── Contact info card ───
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.email_outlined,
                      text: pc.memberEmail,
                      iconColor: const Color(0xFF6366F1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: Colors.grey.withValues(alpha: 0.15),
                        height: 1,
                      ),
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      text: pc.memberPhone,
                      iconColor: const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ─── Completion rate card ───
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3B5BFD,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.pie_chart_rounded,
                            size: 18,
                            color: Color(0xFF3B5BFD),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Task Completion Rate',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.85),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          pc.completionPercent,
                          style: const TextStyle(
                            color: Color(0xFF3B5BFD),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pc.completionRate,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFEEF0F8),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B5BFD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ─── Tabs + content ───
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tab bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _showProjects = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_showProjects
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_showProjects
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.06,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Tasks (${pc.memberTasks.length})',
                                    style: TextStyle(
                                      color: !_showProjects
                                          ? const Color(0xFF3B5BFD)
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _showProjects = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _showProjects
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _showProjects
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.06,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Projects (${pc.memberProjects.length})',
                                    style: TextStyle(
                                      color: _showProjects
                                          ? const Color(0xFF3B5BFD)
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _showProjects
                          ? pc.memberProjects.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Text(
                                      'No projects assigned',
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  )
                                : Column(
                                    key: const ValueKey('projects'),
                                    children: pc.memberProjects
                                        .map(
                                          (p) => _ProjectMiniCard(
                                            item: _ProjectItem(
                                              title: p.title,
                                              company: p.description,
                                              progress: p.progress / 100.0,
                                              progressText: '${p.progress}%',
                                              taskSummary:
                                                  '${p.completedTask}/${p.completedTask + p.remainingTask} tasks completed',
                                              dueText: _formatDeadline(
                                                p.deadLine,
                                              ),
                                              accent: _projectColor(
                                                pc.memberProjects.indexOf(p),
                                              ),
                                              dueColor: _deadlineColor(
                                                p.deadLine,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                          : tasks.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No tasks assigned',
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            )
                          : Column(
                              key: const ValueKey('tasks'),
                              children: tasks
                                  .map((t) => _TaskCard(item: t))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
              // bottom padding for nav bar
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  static String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return '';
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final diff = deadline.difference(today).inDays;
    if (diff > 0) return '${diff}d left';
    if (diff < 0) return '${-diff}d over';
    return 'Today';
  }

  static Color _deadlineColor(DateTime? deadline) {
    if (deadline == null) return const Color(0xFF9CA3AF);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final diff = deadline.difference(today).inDays;
    if (diff < 0) return const Color(0xFFFF4D57);
    return const Color(0xFF10B981);
  }

  static const _projectColors = [
    Color(0xFF2F59F7),
    Color(0xFF0FA885),
    Color(0xFF8B5CF6),
    Color(0xFFE91E63),
  ];

  static Color _projectColor(int index) {
    return _projectColors[index % _projectColors.length];
  }
}

// ─── Supporting widgets ───

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskItem {
  final String title;
  final String project;
  final String status;
  final String due;
  final Color accent;
  final Color statusColor;
  final bool isCompleted;

  const _TaskItem({
    required this.title,
    required this.project,
    required this.status,
    required this.due,
    required this.accent,
    required this.statusColor,
    this.isCompleted = false,
  });
}

class _TaskCard extends StatelessWidget {
  final _TaskItem item;

  const _TaskCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.accent, item.accent.withValues(alpha: 0.3)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: item.statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: item.statusColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.project,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: item.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: item.due.contains('overdue')
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Text(
                item.due,
                style: TextStyle(
                  color: item.due.contains('overdue')
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectItem {
  final String title;
  final String company;
  final double progress;
  final String progressText;
  final String taskSummary;
  final String dueText;
  final Color accent;
  final Color dueColor;

  const _ProjectItem({
    required this.title,
    required this.company,
    required this.progress,
    required this.progressText,
    required this.taskSummary,
    required this.dueText,
    required this.accent,
    required this.dueColor,
  });
}

class _ProjectMiniCard extends StatelessWidget {
  final _ProjectItem item;

  const _ProjectMiniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.accent, item.accent.withValues(alpha: 0.3)],
              ),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.company,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.dueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.dueText,
                  style: TextStyle(
                    color: item.dueColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(item.accent),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.progressText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: item.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.taskSummary,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
