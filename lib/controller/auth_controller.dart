import 'package:get/get.dart';
import 'package:managementt/service/token_service.dart';

class AuthController extends GetxController {

  var isLoggedIn = false.obs;

  @override
  void onInit() {
    checkLogin();
    super.onInit();
  }

  void checkLogin() async {
    String? token = await TokenService.getToken();

    if (token != null) {
      isLoggedIn.value = true;
      Get.offAllNamed("/home");
    } else {
      Get.offAllNamed("/login");
    }
  }

  void login() async {
    String? token = await TokenService.getToken();

    if (token != null) {
      isLoggedIn.value = true;
      Get.offAllNamed("/home");
    } else {
      Get.offAllNamed("/login");
    }
  }

  void logout() async {
  await TokenService.deleteToken();
  Get.offAllNamed("/login");
}

}