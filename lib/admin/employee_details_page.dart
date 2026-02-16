import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/task_detail_page.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/member.dart';

class EmployeeDetailsPage extends StatelessWidget {
  EmployeeDetailsPage({super.key});
  final TaskController _taskController = Get.find<TaskController>();
  @override
  Widget build(BuildContext context) {
    final Member member = Get.arguments;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskController.getTaskByOwner(member.id!);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          member.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ContainerDesign(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email : ${member.email ?? ""}"),
                      Text("Role : ${member.role ?? ""}"),
                      const SizedBox(height: 10),
                      ContainerDesign(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Task",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Obx(() {
                              if (_taskController.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (_taskController.ownerTask.isEmpty) {
                                return Center(
                                  child: Text("No task for ${member.name}"),
                                );
                              }

                              return ListView.builder(
                                itemCount: _taskController.ownerTask.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final task = _taskController.ownerTask[index];
                                  return ProjectCard(
                                    title: task.title,
                                    onTap: () => Get.off(
                                      () => TaskDetailPage(),
                                      arguments: task,
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
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
