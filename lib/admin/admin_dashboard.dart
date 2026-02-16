import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/employee_management_page.dart';
import 'package:managementt/admin/task_detail_page.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});
  final TaskController taskController = Get.put(TaskController());
  final MemberController memberController = Get.put(MemberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              "DashBoard",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Get.to(() => addTask());
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey.withValues(alpha: 0.2),
                ),
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerDesign(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Projects",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (taskController.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (taskController.tasks.isEmpty) {
                          return Center(child: Text("No Tasks Found"));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: taskController.tasks.length,
                          itemBuilder: (context, index) {
                            final project = taskController.tasks[index];
                            return ProjectCard(
                              title: project.title,
                              status: project.status,
                              onTap: () => Get.to(
                                () => TaskDetailPage(),
                                arguments: project,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => EmployeeManagementPage());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
