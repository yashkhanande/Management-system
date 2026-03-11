import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/analytics.dart';
import 'package:managementt/admin/employee_dashboard.dart';
import 'package:managementt/admin/admin_dashboard.dart';
import 'package:managementt/admin/project_dashboard.dart';
import 'package:managementt/components/dashboard_bottom_nav.dart';
import 'package:managementt/controller/admin_nav_controller.dart';
import 'package:managementt/members/member_profile.dart';

class AdminWrapper extends StatelessWidget {
  AdminWrapper({super.key});

  final AdminNavController navController = Get.put(AdminNavController());

  final List<Widget> _pages = [
    const AdminDashboard(),
    ProjectDashboard(),
    EmployeeDashboard(),
    AnalyticsPage(),
    const MemberProfilePage(),
  ];

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
