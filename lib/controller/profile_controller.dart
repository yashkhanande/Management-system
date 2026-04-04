import 'package:get/get.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/member_service.dart';
import 'package:managementt/service/task_service.dart';

class ProfileController extends GetxController {
  final MemberService _memberService = MemberService();
  final TaskService _taskService = TaskService();

  var member = Rxn<Member>();
  var memberTasks = <Task>[].obs;
  var memberProjects = <Task>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = AuthController.to;
    ever(auth.isLoggedIn, (loggedIn) {
      if (loggedIn) loadProfile();
    });
    Future.microtask(() {
      if (auth.isLoggedIn.value && member.value == null) {
        loadProfile();
      }
    });
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final username = AuthController.to.username.value;
      if (username.isEmpty) return;

      final members = await _memberService.getMembers();
      member.value = members.firstWhereOrNull((m) => m.email == username);

      if (member.value?.id != null) {
        final allTasks = await _taskService.getTaskByOwner(member.value!.id!);
        memberTasks.value = allTasks.where((t) => t.type != 'PROJECT').toList();
        memberProjects.value = allTasks
            .where((t) => t.type == 'PROJECT')
            .toList();
      }
    } catch (e) {
      print('ProfileController: Failed to load profile — $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Stats ──

  List<Task> get allOwnerItems => [...memberTasks, ...memberProjects];

  int get totalTasks => allOwnerItems.length;

  int get activeTasks => allOwnerItems
      .where(
        (t) =>
            t.status == 'TODO' ||
            t.status == 'NOT_STARTED' ||
            t.status == 'IN_PROGRESS',
      )
      .length;

  int get doneTasks => allOwnerItems.where((t) => t.status == 'DONE').length;

  int get overdueTasks =>
      allOwnerItems.where((t) => t.status == 'OVERDUE').length;

  double get completionRate {
    if (totalTasks == 0) return 0;
    return doneTasks / totalTasks;
  }

  String get completionPercent =>
      '${(completionRate * 100).toStringAsFixed(0)}%';

  // ── Member info ──

  String get memberName =>
      member.value?.name ?? AuthController.to.username.value;

  String get memberEmail =>
      member.value?.email ?? AuthController.to.username.value;

  String get memberPhone => member.value?.mobileNo ?? '-';

  String get memberRole => member.value?.role ?? AuthController.to.role.value;

  String get initials {
    final name = memberName;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // ── Profile update ──

  final isSaving = false.obs;

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (member.value?.id == null) return false;
    isSaving.value = true;
    try {
      final updated = Member(name: name, mobileNo: phone, tasks: []);
      final result = await _memberService.updateMember(
        member.value!.id!,
        updated,
      );
      member.value = result;
      member.refresh();
      return true;
    } catch (e) {
      print('ProfileController: Failed to update profile — $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isSaving.value = true;
    try {
      final username = AuthController.to.username.value;
      await _memberService.changePassword(
        username: username,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return null; // success
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return msg;
    } finally {
      isSaving.value = false;
    }
  }
}
