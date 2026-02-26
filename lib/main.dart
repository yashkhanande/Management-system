import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/admin_dashboard.dart';
import 'package:managementt/components/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chitale Bandhu',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
      ),
      home: AdminDashboard(),
    );
  }
}
