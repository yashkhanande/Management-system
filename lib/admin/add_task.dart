import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_button.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';

class addTask extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final priorityController = ''.obs;
  final memberController = ''.obs;
  final TextEditingController descriptionController = TextEditingController();
  final TaskController _taskController = Get.find<TaskController>();
  final MemberController _memberController = Get.find<MemberController>();

  addTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Task",
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
                AppTextfield(controller: titleController, label: "Title"),
                const SizedBox(height: 10),
                AppTextfield(
                  controller: descriptionController,
                  label: "Description",
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      "Priority",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    DropdownMenu<String>(
                      width: MediaQuery.widthOf(context) * 0.5,
                      hintText: "Select priority",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "high", label: "High"),
                        DropdownMenuEntry(value: "medium", label: "medium"),
                        DropdownMenuEntry(value: "low", label: "Low"),
                      ],
                      onSelected: (value) {
                        priorityController.value = value ?? '';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      "Member",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      return DropdownMenu<String>(
                        width: MediaQuery.widthOf(context) * 0.5,
                        hintText: "Select Member",
                        dropdownMenuEntries: _memberController.members
                            .map(
                              (member) => DropdownMenuEntry<String>(
                                value: member.id ?? "Unknown member",
                                label: member.name,
                              ),
                            )
                            .toList(),
                        onSelected: (value) {
                          memberController.value = value ?? '';
                        },
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 20),
                Obx(() {
                  return _taskController.isLoading.value
                      ? const CircularProgressIndicator()
                      : AppButton(
                          text: "Add task",
                          onPressed: () async {
                            if (titleController.text.isEmpty ||
                                descriptionController.text.isEmpty ||
                                memberController.value.isEmpty ||
                                priorityController.value.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please fill all fields",
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            await _taskController.addTask(
                              Task(
                                title: titleController.text,
                                description: descriptionController.text,
                                priority: priorityController.value,
                                ownerId: memberController.value,
                              ),
                            );
                            await _memberController.getMembers();
                            Get.back();
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
