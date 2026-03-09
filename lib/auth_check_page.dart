import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/admin_dashboard.dart';
import 'package:managementt/login_page.dart';
import 'package:managementt/service/token_service.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    String? token = await TokenService.getToken();

    if (token != null && token.isNotEmpty) {
      Get.offAll(() => AdminDashboard());
    } else {
      Get.offAll(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}