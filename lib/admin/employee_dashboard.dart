import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/register_employee.dart';
import 'package:managementt/admin/employee_details_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';
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

class EmployeeDashboard extends StatelessWidget {
  EmployeeDashboard({super.key});

  final MemberController memberController = Get.find<MemberController>();
  final TaskController taskController = Get.find<TaskController>();

  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  List<Task> _ownedItems(String memberId) {
    return taskController.tasks.where((t) => t.ownerId == memberId).toList();
  }

  int _projectCount(String memberId) {
    return _ownedItems(
      memberId,
    ).where((t) => (t.type ?? '').toUpperCase() == 'PROJECT').length;
  }

  int _activeProjectCount(String memberId) {
    return _ownedItems(memberId)
        .where(
          (t) =>
              (t.type ?? '').toUpperCase() == 'PROJECT' &&
              (t.status ?? '').toUpperCase() == 'IN_PROGRESS',
        )
        .length;
  }

  int _taskCount(String memberId) {
    return _ownedItems(
      memberId,
    ).where((t) => (t.type ?? '').toUpperCase() == 'TASK').length;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final v = parts.first;
      return v.length >= 2 ? v.substring(0, 2).toUpperCase() : v.toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    if (taskController.tasks.isEmpty && !taskController.isLoading.value) {
      taskController.getAllTask();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: RefreshIndicator(
          onRefresh: () async {
            await TaskService().checkOverdue();
            await memberController.getMembers();
            await taskController.getAllTask();
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
                      /// TITLE ROW
                      Row(
                        children: [
                          const Text(
                            "Employee Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          InkWell(
                            onTap: () {
                              Get.to(() => RegisterEmployees());
                            },
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

                      const SizedBox(height: 4),

                      Text(
                        "Employee overview · $formattedDate",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// EMPLOYEE COUNT (reactive)
                      Obx(
                        () => Text(
                          "${memberController.members.length} total employees",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// SEARCH (reactive with GetX)
                      SizedBox(
                        height: 44,
                        child: TextField(
                          onChanged: (val) =>
                              memberController.searchQuery.value = val,
                          decoration: InputDecoration(
                            hintText: "Search employees..",
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

                const SizedBox(height: 16),

                /// EMPLOYEE LIST
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Obx(() {
                    if (memberController.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final filtered = memberController.filteredMembers;

                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Text("No Members Found"),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final member = filtered[index];
                        final memberId = member.id ?? '';
                        final projectCount = memberId.isEmpty
                            ? 0
                            : _projectCount(memberId);
                        final activeProjectCount = memberId.isEmpty
                            ? 0
                            : _activeProjectCount(memberId);
                        final taskCount = memberId.isEmpty
                            ? 0
                            : _taskCount(memberId);

                        return InkWell(
                          onTap: () {
                            Get.to(
                              () => EmployeeDetailsPage(),
                              arguments: member,
                            );
                          },

                          child: _EmployeeCard(
                            member: member,
                            initials: _initials(member.name),
                            projectCount: projectCount,
                            activeProjectCount: activeProjectCount,
                            taskCount: taskCount,
                            onDelete: () async {
                              final confirmed = await AppConfirmDialog.show(
                                title: 'Delete Employee',
                                message:
                                    'Remove ${member.name} from employees?',
                                cancelText: 'Cancel',
                                confirmText: 'Delete',
                                tone: AppDialogTone.danger,
                                icon: Icons.person_remove_alt_1_rounded,
                              );

                              if (!confirmed) return;
                              if (member.id != null) {
                                await memberController.removeMember(member.id!);
                              }
                            },
                          ),
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

class _EmployeeCard extends StatelessWidget {
  final Member member;
  final String initials;
  final int projectCount;
  final int activeProjectCount;
  final int taskCount;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.member,
    required this.initials,
    required this.projectCount,
    required this.activeProjectCount,
    required this.taskCount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.email ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SmallStat(
                  label: 'Projects',
                  value: '$projectCount',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _SmallStat(
                  label: 'Active',
                  value: '$activeProjectCount',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _SmallStat(
                  label: 'Tasks',
                  value: '$taskCount',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SmallStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
