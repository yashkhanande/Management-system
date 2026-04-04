import 'package:get/get.dart';
import 'package:managementt/components/app_snackbar.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/service/auth_service.dart';
import 'package:managementt/service/member_service.dart';

class MemberController extends GetxController {
  final MemberService _memberService = MemberService();
  final AuthService _authService = AuthService();
  var members = <Member>[].obs;
  var searchQuery = ''.obs;
  var owner = Rxn<Member>();
  var isLoading = false.obs;
  var tasks = <String>[].obs;

  /// Filtered members based on search query — reactive.
  List<Member> get filteredMembers {
    if (searchQuery.value.isEmpty) return members;
    final q = searchQuery.value.toLowerCase();
    return members.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final auth = AuthController.to;
    ever(auth.isLoggedIn, (loggedIn) {
      if (loggedIn) getMembers();
    });
    Future.microtask(() {
      if (auth.isLoggedIn.value && members.isEmpty) {
        getMembers();
      }
    });
  }

  /// Refresh related controllers so dashboard/profile reflect changes.
  void _refreshRelated() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboard();
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }
  }

  Future<void> addMember(Member member) async {
    final normalizedEmail = member.email?.trim().toLowerCase() ?? '';
    final duplicateEmail =
        normalizedEmail.isNotEmpty &&
        members.any(
          (m) => (m.email ?? '').trim().toLowerCase() == normalizedEmail,
        );

    if (duplicateEmail) {
      Get.snackbar('Error', 'An employee with this email already exists');
      return;
    }

    if (normalizedEmail.isNotEmpty) {
      member.email = normalizedEmail;
    }

    isLoading.value = true;
    try {
      await _authService.register(
        member.email!,
        member.password!,
        member.role!,
      );
      await _memberService.addMember(member);
      await getMembers();
      _refreshRelated();
      Get.back();
      AppSnackbar.show('Success', 'Employee added successfully');
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to add member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMembers() async {
    isLoading.value = true;
    try {
      final loaded = await _memberService.getMembers();
      members.value = loaded
          .where((m) => (m.role ?? '').trim().toUpperCase() == 'USER')
          .toList();
    } catch (e) {
      print('MemberController: Failed to fetch members — $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMember(String id) async {
    try {
      await _memberService.removeMember(id);
      await getMembers();
      _refreshRelated();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to remove member: $e');
    }
  }

  Future<void> getMemberById(String id) async {
    try {
      isLoading.value = true;
      owner.value = await _memberService.getMemberById(id);
    } catch (e) {
      owner.value = null;
      Future.microtask(() {
        AppSnackbar.show("Error", e.toString());
      });
    } finally {
      isLoading.value = false;
    }
  }
}
