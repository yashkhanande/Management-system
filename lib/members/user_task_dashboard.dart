import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/controller/user_task_controller.dart';
import 'package:managementt/controller/category_controller.dart';
import 'package:managementt/controller/user_dashboard_controller.dart';
import 'package:managementt/members/user_task_detail_page.dart';
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

class UserTaskDashboard extends StatefulWidget {
  const UserTaskDashboard({super.key});

  @override
  State<UserTaskDashboard> createState() => _UserTaskDashboardState();
}

class _UserTaskDashboardState extends State<UserTaskDashboard> {
  late TextEditingController searchController;
  final searchQuery = ''.obs;
  final selectedStatus = 'ALL'.obs;
  final selectedPriority = 'ALL'.obs;
  final selectedCategory = 'ALL'.obs;
  final UserTaskController taskController = Get.find<UserTaskController>();
  final TaskController allTaskController = Get.find<TaskController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  String _parentProjectName(String? parentId) {
    if (parentId == null || parentId.trim().isEmpty) return 'No parent project';

    final parent = allTaskController.tasks.firstWhereOrNull(
      (t) =>
          t.id == parentId &&
          ((t.type ?? '').toUpperCase() == 'PROJECT' || t.isProject == true),
    );

    final title = parent?.title.trim() ?? '';
    return title.isEmpty ? 'Unknown project' : title;
  }

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
      taskController.fetchUserTasks(userId);
    } else {
      // listen once and fetch when the id becomes available
      once(profileController.member, (val) {
        final newId = val?.id.toString();
        // ignore: avoid_print
        print(
          'UserProjectDashboard: detected userId update, fetching for $newId',
        );
        if (newId != null) taskController.fetchUserTasks(newId);
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

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final dc = Get.find<UserDashboardController>();

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
                      /// TITLE
                      const Text(
                        "My Tasks",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
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
                        final tasks = taskController.userTasks;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              label: 'Total',
                              count: tasks.length,
                              color: const Color(0xFF60A5FA),
                            ),
                            _StatChip(
                              label: 'Active',
                              count: tasks
                                  .where((t) => t.status == 'IN_PROGRESS')
                                  .length,
                              color: const Color(0xFF4ADE80),
                            ),
                            _StatChip(
                              label: 'Done',
                              count: tasks
                                  .where((t) => t.status == 'DONE')
                                  .length,
                              color: const Color(0xFFA78BFA),
                            ),
                            _StatChip(
                              label: 'Overdue',
                              count: tasks
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
                            hintText: "Search tasks…",
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

                      const SizedBox(height: 12),
                      _buildFilterRow(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// TASK LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() {
                    if (dc.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    var filtered = taskController.userTasks.toList();

                    // Apply status filter
                    if (selectedStatus.value != 'ALL') {
                      filtered = filtered.where((task) {
                        final status = (task.status ?? '').toUpperCase();
                        switch (selectedStatus.value) {
                          case 'IN_PROGRESS':
                            return status == 'IN_PROGRESS';
                          case 'DONE':
                            return status == 'DONE' || status == 'COMPLETED';
                          case 'TODO':
                            return status == 'NOT_STARTED' || status == 'TODO';
                          case 'REVIEW':
                            return status == 'REVIEW';
                          case 'OVERDUE':
                            return status == 'OVERDUE';
                          default:
                            return true;
                        }
                      }).toList();
                    }

                    // Apply priority filter
                    if (selectedPriority.value != 'ALL') {
                      filtered = filtered.where((task) {
                        final priority = (task.priority).trim().toUpperCase();
                        return _matchesPriority(
                          priority,
                          selectedPriority.value,
                        );
                      }).toList();
                    }

                    // Apply category filter
                    if (selectedCategory.value != 'ALL') {
                      filtered = filtered.where((task) {
                        final cat = (task.category ?? '').trim().toLowerCase();
                        return cat ==
                            selectedCategory.value.trim().toLowerCase();
                      }).toList();
                    }

                    // Apply search query
                    final query = searchQuery.value.trim().toLowerCase();
                    if (query.isNotEmpty) {
                      filtered = filtered
                          .where((t) => t.title.toLowerCase().contains(query))
                          .toList();
                    }

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No tasks found",
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
                        final task = filtered[index];
                        final parentProjectName = _parentProjectName(
                          task.parentId,
                        );
                        final isDone = AppColors.isCompletedStatus(task.status);
                        final strip = AppColors.stripColor(
                          priority: task.priority,
                          status: task.status,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            // ✅ CLEAN SOFT BACKGROUND COLORS
                            color: task.status == 'DONE'
                                ? const Color(0xFFE8F5E9) // soft green
                                : task.status == 'NOT_STARTED'
                                ? const Color(0xFFFFF8E1) // soft yellow
                                : task.priority == 'Critical'
                                ? const Color(0xFFFFEBEE) // soft red (priority)
                                : task.status == 'OVERDUE'
                                ? const Color(0xFFFFEBEE) // same red family
                                : task.status == 'IN_PROGRESS'
                                ? const Color(0xFFE3F2FD) // soft blue
                                : Colors.white,

                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: task.status == 'DONE'
                                  ? const Color(0xFF81C784) // green
                                  : task.status == 'NOT_STARTED'
                                  ? const Color(0xFFFFD54F) // yellow
                                  : task.priority == 'Critical'
                                  ? const Color(0xFFE57373) // red (priority)
                                  : task.status == 'OVERDUE'
                                  ? const Color(0xFFEF5350) // stronger red
                                  : task.status == 'IN_PROGRESS'
                                  ? const Color(0xFF64B5F6) // blue
                                  : Colors.grey.withOpacity(0.15),
                              width: 1.0,
                            ),

                            // ❌ REMOVED BORDER (very important)

                            // ✅ PROPER SHADOW (depth feel)
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Get.to(() => UserTaskDetailPage(task: task));
                            },

                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                12,
                                12,
                                14,
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔵 STATUS ICON
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color:
                                          (isDone ? AppColors.completed : strip)
                                              .withOpacity(0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isDone
                                          ? Icons.check
                                          : Icons.pending_outlined,
                                      size: 16,
                                      color: isDone
                                          ? AppColors.completed
                                          : strip,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // 📄 CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 🔹 TITLE
                                        Text(
                                          task.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            decorationColor: const Color(
                                              0xFF9CA3AF,
                                            ),
                                            decorationThickness: 2,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        // 🔹 DESCRIPTION
                                        Text(
                                          task.description ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),

                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.folder_open_rounded,
                                              size: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                parentProjectName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF475569),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // 🔹 BADGES
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _Badge(
                                              text: isDone
                                                  ? 'Done'
                                                  : _statusLabel(task.status),
                                              bg:
                                                  (isDone
                                                          ? AppColors.completed
                                                          : strip)
                                                      .withOpacity(0.10),
                                              fg: isDone
                                                  ? AppColors.completed
                                                  : strip,
                                            ),

                                            _Badge(
                                              text: dc.formatDeadline(
                                                task.deadLine,
                                              ),
                                              bg: const Color(0xFFFFF4E5),
                                              fg: const Color(0xFFF59E0B),
                                              icon:
                                                  Icons.calendar_today_rounded,
                                            ),

                                            _Badge(
                                              text: '#${task.priority}',
                                              bg: const Color(0xFFEEF2FF),
                                              fg: const Color(0xFF4F46E5),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _statusLabel(String? status) {
    final s = (status ?? '').toUpperCase();
    switch (s) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'NOT_STARTED':
      case 'TODO':
        return 'Todo';
      case 'REVIEW':
        return 'Review';
      case 'OVERDUE':
        return 'Overdue';
      case 'DONE':
      case 'COMPLETED':
        return 'Done';
      default:
        return 'Task';
    }
  }

  Widget _buildFilterRow() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Status',
                  value: selectedStatus.value,
                  hintText: 'Select status',
                  options: _statusOptions.keys.toList(),
                  labelBuilder: (v) => _statusOptions[v] ?? v,
                  onChanged: (val) {
                    if (val == null) return;
                    selectedStatus.value = val;
                    if (val != 'ALL') {
                      selectedPriority.value = 'ALL';
                      selectedCategory.value = 'ALL';
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Priority',
                  value: selectedPriority.value,
                  hintText: 'Select priority',
                  options: _priorityOptions,
                  labelBuilder: (v) => v,
                  onChanged: (val) {
                    if (val == null) return;
                    selectedPriority.value = val;
                    if (val != 'ALL') {
                      selectedStatus.value = 'ALL';
                      selectedCategory.value = 'ALL';
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Category',
                  value: selectedCategory.value,
                  hintText: 'Select category',
                  options: _categoryOptions,
                  labelBuilder: (v) => v,
                  onChanged: (val) {
                    if (val == null) return;
                    selectedCategory.value = val;
                    if (val != 'ALL') {
                      selectedStatus.value = 'ALL';
                      selectedPriority.value = 'ALL';
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
              style: const TextStyle(
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
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.35,
                      ),
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

  static const Map<String, String> _statusOptions = {
    'ALL': 'ALL',
    'IN_PROGRESS': 'IN PROGRESS',
    'DONE': 'DONE',
    'TODO': 'NOT STARTED',
    'REVIEW': 'UNDER REVIEW',
    'OVERDUE': 'OVERDUE',
  };

  static const List<String> _priorityOptions = [
    'ALL',
    'Critical',
    'High',
    'Moderate',
    'Low',
  ];

  List<String> get _categoryOptions {
    final opts = categoryController.dropdownOptions;
    if (opts.contains('ALL')) return opts;
    return ['ALL', ...opts];
  }

  bool _matchesPriority(String taskPriority, String selected) {
    final p = taskPriority.trim().toUpperCase();
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

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Badge({
    required this.text,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
