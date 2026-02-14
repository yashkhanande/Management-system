import 'package:get/get.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/service/member_service.dart';

class MemberController extends GetxController {
  final MemberService _memberService = MemberService();
  var members = <Member>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    getMembers();
    super.onInit();
  }

  void addMember(Member member) async {
    isLoading.value = true;
    await _memberService.addMember(member);
    getMembers();
    isLoading.value = false;
  }

  void getMembers() async {
    isLoading.value = true;
    members.value = await _memberService.getMembers();
    isLoading.value = false;
  }

  void removeMember(String id) async {
    await _memberService.removeMember(id);
    getMembers();
  }
}
