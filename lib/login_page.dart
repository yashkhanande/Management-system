import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_button.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/service/auth_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _isLoading = false.obs;

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
                          color: AppColors.primaryBlue,
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
                        color: Colors.black.withValues(alpha: 0.03),
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
                        label: "Email",
                      ),
                      const SizedBox(height: 20),
                      AppTextfield(
                        controller: passwordController,
                        label: "Password",
                      ),
                      const SizedBox(height: 40),
                      Obx(
                        () => _isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : AppButton(
                                text: "Login",
                                buttonColor: AppColors.primaryBlue,
                                onPressed: () async {
                                  final email = userIdController.text.trim();
                                  final password = passwordController.text
                                      .trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    Get.snackbar(
                                      'Error',
                                      'Please enter both Email and Password',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }

                                  _isLoading.value = true;
                                  try {
                                    final authResponse = await _authService
                                        .login(email, password);
                                    await AuthController.to.setAuthData(
                                      authResponse,
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'Login Failed',
                                      e.toString(),
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } finally {
                                    _isLoading.value = false;
                                  }
                                },
                              ),
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
