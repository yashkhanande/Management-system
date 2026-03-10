import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/register_employee.dart';
import 'package:managementt/admin/employee_details_page.dart';
import 'package:managementt/components/animated_gradient_container.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/controller/task_controller.dart';

class ProjectDashboard extends StatelessWidget {
  ProjectDashboard({super.key});
  final TaskController taskController = Get.put(TaskController());
  final int totalProjectCount = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Project Dashboard",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Get.to(() => AddTask());
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.blueGrey,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          AnimatedGradientContainer(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              20,
              14,
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$totalProjectCount total projects",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      hintText: "Search employees..",
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (taskController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (taskController.tasks.isEmpty) {
                return Center(child: Text("No project Found"));
              }

              return ListView.builder(
                itemCount: taskController.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskController.tasks[index];

                  return InkWell(
                    onTap: () {
                      Get.to(() => EmployeeDetailsPage(), arguments: task);
                    },
                    child: ContainerDesign(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: Text("Confirm Remove"),
                                  content: Text(
                                    "Are you sure you want to remove ${task.title} ?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (task.id != null) {
                                          taskController.removeTask(task.id!);
                                        }
                                        Get.back();
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
