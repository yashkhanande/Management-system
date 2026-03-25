import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';

enum UserAssignmentsView { projects, tasks }

class UserAssignmentsPage extends StatefulWidget {
  final Member member;
  final UserAssignmentsView initialView;
  final String? initialStatusFilter;

  const UserAssignmentsPage({
    super.key,
    required this.member,
    this.initialView = UserAssignmentsView.projects,
    this.initialStatusFilter,
  });

  @override
  State<UserAssignmentsPage> createState() => _UserAssignmentsPageState();
}

class _UserAssignmentsPageState extends State<UserAssignmentsPage> {
  final TaskController _taskController = Get.find<TaskController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _statusFilter;
  late UserAssignmentsView _currentView;

  static const List<_StatusFilterOption> _statusFilters = [
    _StatusFilterOption('ALL', 'All'),
    _StatusFilterOption('TODO', 'Todo'),
    _StatusFilterOption('IN_PROGRESS', 'In Progress'),
    _StatusFilterOption('REVIEW', 'Review'),
    _StatusFilterOption('DONE', 'Done'),
    _StatusFilterOption('OVERDUE', 'Overdue'),
  ];

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
    _statusFilter = widget.initialStatusFilter ?? 'ALL';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = widget.member.id;
      if (ownerId != null && ownerId.isNotEmpty) {
        _taskController.getTaskByOwner(ownerId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _viewLabel =>
      _currentView == UserAssignmentsView.projects ? 'Projects' : 'Tasks';

  String get _firstName {
    final trimmed = widget.member.name.trim();
    if (trimmed.isEmpty) return widget.member.name;
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Future<void> _refreshAssignments() async {
    final ownerId = widget.member.id;
    if (ownerId != null && ownerId.isNotEmpty) {
      await _taskController.getTaskByOwner(ownerId);
    }
  }

  void _updateView(UserAssignmentsView view) {
    if (_currentView == view) return;
    setState(() {
      _currentView = view;
      _statusFilter = 'ALL';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<Task> _filteredItems(List<Task> owned) {
    final targetType = _currentView == UserAssignmentsView.projects
        ? 'PROJECT'
        : 'TASK';
    var filtered = owned
        .where((task) => (task.type ?? '').toUpperCase() == targetType)
        .toList();

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((task) {
        final inTitle = task.title.toLowerCase().contains(query);
        final inDescription = task.description.toLowerCase().contains(query);
        return inTitle || inDescription;
      }).toList();
    }

    if (_statusFilter != 'ALL') {
      filtered = filtered.where((task) {
        final status = (task.status ?? '').toUpperCase();
        switch (_statusFilter) {
          case 'TODO':
            return status == 'TODO' || status == 'NOT_STARTED';
          case 'IN_PROGRESS':
            return status == 'IN_PROGRESS';
          case 'REVIEW':
            return status == 'REVIEW';
          case 'DONE':
            return status == 'DONE' || status == 'COMPLETED';
          case 'OVERDUE':
            return status == 'OVERDUE';
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  void _handleItemTap(Task task) {
    if (_currentView == UserAssignmentsView.projects) {
      Get.to(
        () => ProjectDetailPage(
          project: task,
          projectMemberNames: [widget.member.name],
        ),
      );
      return;
    }

    final parent = _findParentProject(task);
    if (parent != null) {
      Get.to(
        () => ProjectDetailPage(
          project: parent,
          projectMemberNames: [widget.member.name],
        ),
      );
    }
  }

  Task? _findParentProject(Task task) {
    for (final candidate in _taskController.tasks) {
      final sameId = candidate.id == task.parentId;
      final isProject = (candidate.type ?? '').toUpperCase() == 'PROJECT';
      if (sameId && isProject) {
        return candidate;
      }
    }
    return null;
  }

  String _deadlineLabel(DateTime? deadline) {
    return DateTimeHelper.remainingDaysLabel(deadline);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          _buildHeader(topPad),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search ${_viewLabel.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusFilters(),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final owned = _taskController.ownerTask;
              final filtered = _filteredItems(owned);
              final isLoading = _taskController.isLoading.value;

              if (isLoading && owned.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filtered.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshAssignments,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    children: [
                      Center(
                        child: Text(
                          'No ${_viewLabel.toLowerCase()} match your filters',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshAssignments,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return _AssignmentTile(
                      task: task,
                      subtitle: task.description,
                      deadlineLabel: _deadlineLabel(task.deadLine),
                      onTap: () => _handleItemTap(task),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: Get.back,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.member.role ?? 'Employee',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            widget.member.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_firstName}'s $_viewLabel",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ViewToggleChip(
                label: 'Projects',
                selected: _currentView == UserAssignmentsView.projects,
                onSelected: () => _updateView(UserAssignmentsView.projects),
              ),
              const SizedBox(width: 8),
              _ViewToggleChip(
                label: 'Tasks',
                selected: _currentView == UserAssignmentsView.tasks,
                onSelected: () => _updateView(UserAssignmentsView.tasks),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statusFilters.map((option) {
          final selected = _statusFilter == option.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: selected,
              onSelected: (_) => setState(() => _statusFilter = option.value),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : const Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final Task task;
  final String subtitle;
  final String deadlineLabel;
  final VoidCallback? onTap;

  const _AssignmentTile({
    required this.task,
    required this.subtitle,
    required this.deadlineLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final strip = AppColors.stripColor(
      priority: task.priority,
      status: task.status,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle.isEmpty ? 'No description provided' : subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  text: _statusLabel(task.status),
                  fg: strip,
                  bg: strip.withValues(alpha: 0.12),
                  icon: Icons.circle,
                  iconSize: 8,
                ),
                _Badge(
                  text: deadlineLabel,
                  fg: const Color(0xFF0F172A),
                  bg: const Color(0xFFF1F5F9),
                  icon: Icons.calendar_today_rounded,
                ),
                if ((task.priority).isNotEmpty)
                  _Badge(
                    text: '#${task.priority}',
                    fg: const Color(0xFF6366F1),
                    bg: const Color(0xFFEEF2FF),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String? value) {
    final status = (value ?? '').toUpperCase();
    switch (status) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'REVIEW':
        return 'Review';
      case 'OVERDUE':
        return 'Overdue';
      case 'NOT_STARTED':
      case 'TODO':
        return 'Todo';
      case 'DONE':
      case 'COMPLETED':
        return 'Done';
      default:
        return 'Task';
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  final IconData? icon;
  final double iconSize;

  const _Badge({
    required this.text,
    required this.fg,
    required this.bg,
    this.icon,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _ViewToggleChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1E1B4B) : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusFilterOption {
  final String value;
  final String label;

  const _StatusFilterOption(this.value, this.label);
}
