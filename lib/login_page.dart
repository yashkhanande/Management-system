import 'package:flutter/material.dart';
import 'package:managementt/components/app_button.dart';
import 'package:managementt/components/app_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome again!",
                style: TextStyle(
                  color: Color.fromARGB(255, 104, 79, 162),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("UserId"),
                    const SizedBox(height: 10),
                    AppTextfield(controller: userIdController, label: "UserId"),
                    const SizedBox(height: 10),
                    Text("Password"),
                    const SizedBox(height: 10),
                    AppTextfield(
                      controller: passwordController,
                      label: "Password",
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      text: "Login",
                      onPressed: () async {
                        print(
                          "Login done  , userIdController.text ${userIdController.text}",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
