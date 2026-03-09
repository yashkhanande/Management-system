import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:managementt/admin/admin_dashboard.dart';
import 'package:managementt/components/app_button.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/config.dart';
import 'package:managementt/service/token_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                // Logo/Title Section
                Container(
                  margin: EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business_center_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Management System",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Login Card
                Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Please sign in to continue",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppTextfield(
                        controller: userIdController,
                        label: "User ID",
                      ),
                      const SizedBox(height: 20),
                      AppTextfield(
                        controller: passwordController,
                        label: "Password",
                      ),
                      const SizedBox(height: 40),
                      AppButton(
                        text: "Login",
                        buttonColor: Color(0xFF2563EB),

                        onPressed: () async {
                          final response = await http.post(
                            Uri.parse("${Config.baseUrl}/auth/login"),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({
                              "username": userIdController.text,
                              "password": passwordController.text,
                            }),
                          );

                          if (response.statusCode == 200) {
                            String token = response.body;

                            await TokenService.saveToken(token);

                            print("JWT: $token");

                            Get.offAll(() => AdminDashboard());
                          }else{
                            print("nothing is happening ");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
