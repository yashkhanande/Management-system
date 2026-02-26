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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Card(
            elevation: 9,
            child: Container(
              height: 300,
              color: Colors.amber,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome again!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 104, 79, 162),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("UserId"),
                  AppTextfield(controller: userIdController, label: "UserId"),
                  Text("Password"),
                  AppTextfield(
                    controller: passwordController,
                    label: "Password",
                  ),
                  AppButton(
                    text: "Login",
                    onPressed: () async {
                      print("Login done");
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
