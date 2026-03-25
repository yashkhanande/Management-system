import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/user_dashboard_bottom_nav.dart';
import 'package:managementt/controller/user_nav_controller.dart';
import 'package:managementt/members/user_dashboard.dart';
import 'package:managementt/members/user_project_dashboard.dart';
import 'package:managementt/members/user_task_dashboard.dart';
import 'package:managementt/members/user_analytics.dart';

class UserWrapper extends StatelessWidget {
  UserWrapper({super.key});

  final UserNavController navController = Get.put(UserNavController());

  final List<Widget> _pages = [
    const UserDashboard(),
    const UserProjectDashboard(),
    const UserTaskDashboard(),
    const UserAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    if (navController.currentIndex.value >= _pages.length) {
      navController.currentIndex.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navController.pageController.hasClients) {
          navController.pageController.jumpToPage(0);
        }
      });
    }

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: navController.pageController,
        onPageChanged: navController.onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: const UserDashboardBottomNav(),
    );
  }
}
