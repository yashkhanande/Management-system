import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_button.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/model/member.dart';

class AddEmployee extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  // final TextEditingController positionController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  final MemberController memberController = MemberController();

  AddEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Employee",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                AppTextfield(controller: nameController, label: "Name"),
                SizedBox(height: 20),
                Obx(() {
                  return memberController.isLoading.value
                      ? const CircularProgressIndicator()
                      : AppButton(
                          text: "Add Employee",
                          onPressed: () {
                            if (nameController.text.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please fill all fields",
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            memberController.addMember(
                              Member(
                                name: nameController.text,
                                // position: positionController.text,
                                // email: emailController.text,
                                // phone: phoneController.text,
                                tasks: [],
                              ),
                            );
                          },
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
