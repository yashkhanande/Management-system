import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/analytics.dart';
import 'package:managementt/admin/employee_dashboard.dart';
import 'package:managementt/admin/admin_dashboard.dart';
import 'package:managementt/admin/project_dashboard.dart';
import 'package:managementt/components/dashboard_bottom_nav.dart';
import 'package:managementt/controller/admin_nav_controller.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/task_controller.dart';

class AdminWrapper extends StatefulWidget {
  const AdminWrapper({super.key});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  final AdminNavController navController = Get.find<AdminNavController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final TaskController taskController = Get.find<TaskController>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboard(),
      ProjectDashboard(),
      EmployeeDashboard(),
      const AnalyticsPage(),
    ];

    if (navController.currentIndex.value >= _pages.length) {
      navController.currentIndex.value = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navController.pageController.hasClients) {
        navController.pageController.jumpToPage(navController.currentIndex.value);
      }
      dashboardController.loadDashboard();
      taskController.getAllTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: navController.pageController,
        onPageChanged: navController.onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: const DashboardBottomNav(),
    );
  }
}
