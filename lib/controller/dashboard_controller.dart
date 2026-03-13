import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/model/activity.dart';
import 'package:managementt/model/dashboard_models.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/activity_service.dart';
import 'package:managementt/service/member_service.dart';
import 'package:managementt/service/task_service.dart';

class DashboardController extends GetxController {
  final TaskService _taskService = TaskService();
  final ActivityService _activityService = ActivityService();
  final MemberService _memberService = MemberService();

  var projects = <Task>[].obs;
  var tasks = <Task>[].obs;
  var activities = <Activity>[].obs;
  var members = <Member>[].obs;
  var isLoading = false.obs;
  var currentMember = Rxn<Member>();

  List<Task> get allItems => [...projects, ...tasks];

  @override
  void onInit() {
    super.onInit();
    final auth = AuthController.to;
    ever(auth.isLoggedIn, (loggedIn) {
      if (loggedIn) loadDashboard();
    });
    // Deferred check: if auth was already restored before ever() registered.
    Future.microtask(() {
      if (auth.isLoggedIn.value && projects.isEmpty && tasks.isEmpty) {
        loadDashboard();
      }
    });
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      // Keep dashboard useful even if one backend endpoint fails.
      List<Task> loadedProjects = const [];
      List<Task> loadedTasks = const [];
      List<Activity> loadedActivities = const [];
      List<Member> loadedMembers = const [];

      try {
        loadedProjects = await _taskService.getTasksByType('PROJECT');
      } catch (e) {
        print('DashboardController: Failed to load projects — $e');
      }

      try {
        loadedTasks = await _taskService.getTasksByType('TASK');
      } catch (e) {
        print('DashboardController: Failed to load tasks — $e');
      }

      try {
        loadedActivities = await _activityService.getActivities();
      } catch (e) {
        print('DashboardController: Failed to load activities — $e');
      }

      try {
        loadedMembers = await _memberService.getMembers();
      } catch (e) {
        print('DashboardController: Failed to load members — $e');
      }

      projects.value = loadedProjects;
      tasks.value = loadedTasks;
      activities.value = loadedActivities;
      members.value = loadedMembers;

      final username = AuthController.to.username.value;
      if (username.isNotEmpty) {
        currentMember.value = members.firstWhereOrNull(
          (m) => m.email == username,
        );
      }
    } catch (e) {
      print('DashboardController: Failed to load dashboard — $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Stat card values ──

  int get projectCount => projects.length;

  int get activeProjectCount =>
      projects.where((p) => p.status == 'IN_PROGRESS').length;

  int get totalTaskCount => tasks.length;

  int get overdueCount => projects.where((p) => p.status == 'OVERDUE').length;

  // ── Donut chart data ──

  List<StatusData> get statusData {
    final all = projects;
    final done = all.where((p) => p.status == 'DONE').length;
    final inProgress = all.where((p) => p.status == 'IN_PROGRESS').length;
    final notStarted = all.where((p) => p.status == 'NOT_STARTED').length;
    final overdue = all.where((p) => p.status == 'OVERDUE').length;
    return [
      StatusData(label: 'Done', count: done, color: AppColors.success),
      StatusData(
        label: 'In Progress',
        count: inProgress,
        color: AppColors.info,
      ),
      StatusData(
        label: 'Not Started',
        count: notStarted,
        color: const Color(0xFFD1D5DB),
      ),
      StatusData(label: 'Overdue', count: overdue, color: AppColors.warning),
    ];
  }

  String get completionPercent {
    if (projects.isEmpty) return '0';
    final done = projects.where((p) => p.status == 'DONE').length;
    return ((done / projects.length) * 100).toStringAsFixed(0);
  }

  // ── Header info ──

  String get welcomeName {
    if (currentMember.value != null) {
      final fullName = currentMember.value!.name.trim();
      if (fullName.isNotEmpty) {
        return fullName.split(RegExp(r'\s+')).first;
      }
    }
    final username = AuthController.to.username.value;
    if (username.isNotEmpty) {
      final beforeAt = username.split('@').first.trim();
      if (beforeAt.isNotEmpty) return beforeAt;
    }
    return 'Admin';
  }

  String get formattedDate {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
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
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ── Member helpers ──

  String getMemberName(String ownerId) {
    final member = members.firstWhereOrNull((m) => m.id == ownerId);
    return member?.name ?? 'Unknown';
  }

  String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String getMemberInitials(String ownerId) {
    return getInitials(getMemberName(ownerId));
  }

  // ── Date formatting ──

  String formatDeadline(DateTime? deadline) {
    if (deadline == null) return '';
    return DateTimeHelper.remainingDaysLabel(deadline);
  }

  Color deadlineColor(DateTime? deadline) {
    if (deadline == null) return AppColors.warning;
    final diff = DateTimeHelper.remainingDays(deadline);
    if (diff < 0) return AppColors.error;
    if (diff <= 7) return AppColors.warning;
    return AppColors.success;
  }

  String formatRelativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  // ── Dashboard section data ──

  List<AlertItem> get criticalAlerts {
    const thresholdDays = 7;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final alerts = <AlertItem>[];
    for (final p in projects.where((p) => p.deadLine != null)) {
      final remaining = p.deadLine!.difference(today).inDays;
      if (remaining <= thresholdDays) {
        final subtitle = remaining < 0
            ? '${-remaining}d past deadline'
            : remaining == 0
            ? 'Due today'
            : '$remaining d remaining';
        alerts.add(AlertItem(title: p.title, subtitle: subtitle));
      }
    }
    alerts.sort((a, b) => a.subtitle.compareTo(b.subtitle));
    return alerts;
  }

  List<DeadlineItem> get deadlineItems {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final withDeadlines = projects.where((p) => p.deadLine != null).toList();
    // Least remaining days first
    withDeadlines.sort((a, b) {
      final remainA = a.deadLine!.difference(today).inDays;
      final remainB = b.deadLine!.difference(today).inDays;
      return remainA.compareTo(remainB);
    });
    return withDeadlines.take(5).map((p) {
      final ownerName = getMemberName(p.ownerId);
      return DeadlineItem(
        title: p.title,
        subtitle: p.description,
        due: formatDeadline(p.deadLine),
        accent: deadlineColor(p.deadLine),
        initials: getInitials(ownerName),
      );
    }).toList();
  }

  List<ActivityItem> get activityItems {
    return activities.take(5).map((a) {
      return ActivityItem(
        initials: getInitials(a.userName),
        message: '${a.userName} ${a.verb} "${a.projectName}"',
        project: a.projectName,
        when: formatRelativeTime(a.time),
      );
    }).toList();
  }

  Color projectAccent(Task item) {
    return AppColors.stripColor(priority: item.priority, status: item.status);
  }

  // ── Analytics computed properties ──

  /// Percentage of all items that are not overdue.
  String get onTimePercent {
    if (allItems.isEmpty) return '0';
    final overdue = allItems.where((t) => t.status == 'OVERDUE').length;
    return (((allItems.length - overdue) / allItems.length) * 100)
        .toStringAsFixed(0);
  }

  int get overdueTaskCount =>
      allItems.where((t) => t.status == 'OVERDUE').length;

  /// Count of all items that are assigned to a member.
  String get coveragePercent {
    if (allItems.isEmpty) return '0';
    final assigned = allItems.where((t) => t.ownerId.isNotEmpty).length;
    return ((assigned / allItems.length) * 100).toStringAsFixed(0);
  }

  int get assignedCount => allItems.where((t) => t.ownerId.isNotEmpty).length;

  // ── Priority breakdown ──
  int get highPriorityCount =>
      allItems.where((t) => t.priority.toLowerCase() == 'high').length;
  int get mediumPriorityCount =>
      allItems.where((t) => t.priority.toLowerCase() == 'medium').length;
  int get lowPriorityCount =>
      allItems.where((t) => t.priority.toLowerCase() == 'low').length;

  // ── At-risk deadlines (overdue items) ──
  List<Task> get atRiskTasks =>
      allItems.where((t) => t.status == 'OVERDUE').toList();

  // ── Team task distribution ──
  /// Returns a map of memberId → {name, done, active, todo}
  List<Map<String, dynamic>> get teamDistribution {
    final result = <Map<String, dynamic>>[];
    for (final m in members) {
      final memberTasks = allItems.where((t) => t.ownerId == m.id).toList();
      result.add({
        'name': m.name.split(' ').first,
        'done': memberTasks.where((t) => t.status == 'DONE').length,
        'active': memberTasks
            .where((t) => t.status == 'IN_PROGRESS' || t.status == 'TODO')
            .length,
        'todo': memberTasks.where((t) => t.status == 'NOT_STARTED').length,
      });
    }
    return result;
  }

  // ── Top contributors (ranked by done tasks) ──
  List<Map<String, dynamic>> get topContributors {
    final contributors = <Map<String, dynamic>>[];
    for (final m in members) {
      final doneCount = allItems
          .where((t) => t.ownerId == m.id && t.status == 'DONE')
          .length;
      contributors.add({
        'name': m.name,
        'initials': getInitials(m.name),
        'tasksCompleted': doneCount,
      });
    }
    contributors.sort(
      (a, b) =>
          (b['tasksCompleted'] as int).compareTo(a['tasksCompleted'] as int),
    );
    return contributors.take(5).toList();
  }

  // ── Project health items ──
  List<Map<String, dynamic>> get projectHealthItems {
    final result = <Map<String, dynamic>>[];
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    for (final p in projects) {
      String status;
      Color statusColor;
      String timeInfo;

      if (p.status == 'OVERDUE') {
        status = 'Critical';
        statusColor = const Color(0xFFEF4444);
        final daysOver = p.deadLine != null
            ? today.difference(p.deadLine!).inDays
            : 0;
        timeInfo = '${daysOver}d overdue';
      } else if (p.deadLine != null &&
          p.deadLine!.difference(today).inDays <= 7) {
        status = 'At Risk';
        statusColor = const Color(0xFFF59E0B);
        timeInfo = '${p.deadLine!.difference(today).inDays}d remaining';
      } else {
        status = 'On Track';
        statusColor = const Color(0xFF10B981);
        timeInfo = p.deadLine != null
            ? '${p.deadLine!.difference(today).inDays}d remaining'
            : '';
      }

      result.add({
        'name': p.title,
        'description': p.description,
        'status': status,
        'statusColor': statusColor,
        'healthPercent': p.progress,
        'timeInfo': timeInfo,
      });
    }
    return result;
  }
}
