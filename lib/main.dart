import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/admin_wrapper.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/admin_nav_controller.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register controllers permanently so they stay alive
  // and can cross-refresh each other for real-time updates.
  Get.put(AuthController(), permanent: true);
  Get.put(TaskController(), permanent: true);
  Get.put(MemberController(), permanent: true);
  Get.put(DashboardController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(AdminNavController(), permanent: true);

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
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      home: SplashScreen(),
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
        return LoginPage();
      }

      // Session restored — render the correct dashboard directly.
      if (auth.role.value == 'ADMIN') {
        return AdminWrapper();
      } else {
        return AdminWrapper();
      }
    });
  }
}
