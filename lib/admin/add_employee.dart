import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_button.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/model/member.dart';

class AddEmployee extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final roleController = ''.obs;
  final TextEditingController emailController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  final MemberController memberController = Get.find<MemberController>();

  AddEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Employee",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                AppTextfield(controller: nameController, label: "Name"),
                const SizedBox(height: 10),
                AppTextfield(controller: emailController, label: "Email"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      "Role",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    DropdownMenu<String>(
                      width: MediaQuery.widthOf(context) * 0.5,
                      hintText: "Select employee role",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "user", label: "User"),
                        DropdownMenuEntry(value: "admin", label: "Admin"),
                      ],
                      onSelected: (value) {
                        roleController.value = value ?? '';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                                role: roleController.value,
                                email: emailController.text,
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
