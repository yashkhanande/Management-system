import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_employee.dart';
import 'package:managementt/admin/admin_dashboard.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/login_page.dart';
import 'package:managementt/members/member_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register controllers — AuthController first so others can use it.
  Get.put(AuthController());
  Get.lazyPut(() => TaskController());
  Get.lazyPut(() => MemberController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Management System',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
      ),
      home: AddEmployee(),
    );
  }
}

/// Shown at startup. Waits for [AuthController] to restore the session from
/// secure storage, then renders the correct screen reactively — no
/// Get.offAll needed (the navigator may not be ready during onInit).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = AuthController.to;

      // Still reading from secure storage.
      if (auth.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // No saved session — show login.
      if (!auth.isLoggedIn.value) {
        return AddEmployee();
      }

      // Session restored — render the correct dashboard directly.
      if (auth.role.value == 'ADMIN') {
        return AddEmployee();
      } else {
        return AddEmployee();
      }
    });
  }
}
