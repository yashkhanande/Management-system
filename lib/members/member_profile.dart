import 'package:flutter/material.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  bool _showProjects = false;
  bool _isLoadingProjects = false;
  List<_ProjectItem> _loadedProjects = const [];

  Future<void> _loadProjectsIfNeeded() async {
    if (_loadedProjects.isNotEmpty || _isLoadingProjects) return;
    setState(() => _isLoadingProjects = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _loadedProjects = const [
        _ProjectItem(
          title: 'E-Commerce Platform Redesign',
          company: 'ShopNow Inc.',
          progress: 0.78,
          progressText: '78%',
          taskSummary: '1/2 tasks completed',
          dueText: '9d over',
          accent: Color(0xFF2F59F7),
          dueColor: Color(0xFFFF4D57),
        ),
        _ProjectItem(
          title: 'Mobile Banking App v2',
          company: 'TrustBank Corp.',
          progress: 0.35,
          progressText: '35%',
          taskSummary: '1/3 tasks completed',
          dueText: '36d left',
          accent: Color(0xFF0FA885),
          dueColor: Color(0xFF10B981),
        ),
        _ProjectItem(
          title: 'AI Analytics Dashboard',
          company: 'DataViz Ltd.',
          progress: 0.08,
          progressText: '8%',
          taskSummary: '0/1 tasks completed',
          dueText: '66d left',
          accent: Color(0xFF8B5CF6),
          dueColor: Color(0xFF8B5CF6),
        ),
      ];
      _isLoadingProjects = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = <_TaskItem>[
      const _TaskItem(
        title: 'UI Component Library Setup',
        project: 'E-Commerce Platform Redesign',
        status: 'Done',
        due: 'Dec 20',
        accent: Color(0xFFE91E63),
        statusColor: Color(0xFF22C55E),
        isCompleted: true,
      ),
      const _TaskItem(
        title: 'Checkout Flow Optimization',
        project: 'E-Commerce Platform Redesign',
        status: 'In Progress',
        due: '14d overdue',
        accent: Color(0xFFFFD54F),
        statusColor: Color(0xFF3B82F6),
      ),
      const _TaskItem(
        title: 'Leave Management Module',
        project: 'HR Management System',
        status: 'Done',
        due: 'Dec 15',
        accent: Color(0xFFE91E63),
        statusColor: Color(0xFF22C55E),
        isCompleted: true,
      ),
      const _TaskItem(
        title: 'ML Model Integration',
        project: 'AI Analytics Dashboard',
        status: 'To Do',
        due: 'Apr 1',
        accent: Color(0xFFE91E63),
        statusColor: Color(0xFF9CA3AF),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6D70F6), Color(0xFF8986F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C66EA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Center(
                            child: Text(
                              'SC',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sarah Chen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Senior Developer',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Engineering',
                                  style: TextStyle(
                                    color: Color(0xFF5C66EA),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: _StatCard(
                            count: '4',
                            label: 'Total',
                            icon: Icons.assignment,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            count: '2',
                            label: 'Active',
                            icon: Icons.bar_chart,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            count: '2',
                            label: 'Done',
                            icon: Icons.task_alt,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            count: '1',
                            label: 'Overdue',
                            icon: Icons.priority_high,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const _InfoRow(
                      icon: Icons.email_outlined,
                      text: 'sarah.chen@company.com', c: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    const _InfoRow(
                      icon: Icons.phone_outlined,
                      text: '1 (555) 234 5678', c: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    const _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      text: 'Joined March 15, 2023', c: Colors.blueGrey,
                    ),
                    const SizedBox(height: 7),
                    Divider(color: Colors.grey.withValues(alpha: 0.3)),
                    // const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          'Task Completion Rate',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.85),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '50%',
                          style: TextStyle(
                            color: Color(0xFF3B5BFD),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 4,
                        backgroundColor: Color(0xFFDBDDF0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B5BFD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => _showProjects = false);
                          },
                          child: Text(
                            'Tasks (4)',
                            style: TextStyle(
                              color: !_showProjects
                                  ? const Color(0xFF3B5BFD)
                                  : const Color(0xFF6B7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {
                            setState(() => _showProjects = true);
                            await _loadProjectsIfNeeded();
                          },
                          child: Text(
                            'Projects (3)',
                            style: TextStyle(
                              color: _showProjects
                                  ? const Color(0xFF3B5BFD)
                                  : const Color(0xFF6B7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.only(left: _showProjects ? 74 : 0),
                        width: 58,
                        height: 2,
                        color: const Color(0xFF3B5BFD),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_showProjects)
                      if (_isLoadingProjects)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      else
                        ..._loadedProjects.map(
                          (project) => _ProjectMiniCard(item: project),
                        )
                    else
                      ...tasks.map((task) => _TaskCard(item: task)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFA9ACFF).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
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
  final Color c;

  const _InfoRow({required this.icon, required this.text, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFE3E7F4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF7C8599)),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: c,
            fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFE2EA)),
      ),
      child: Column(
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: item.accent,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  item.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.statusColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '• ${item.project}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF59637A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                item.status,
                style: TextStyle(
                  color: item.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                item.due,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
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
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFE2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: item.accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      item.company,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7B869C),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.dueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.dueText,
                  style: TextStyle(
                    color: item.dueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFDDE2F5),
                    valueColor: AlwaysStoppedAnimation<Color>(item.accent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.progressText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.taskSummary,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B869C),
            ),
          ),
        ],
      ),
    );
  }
}
