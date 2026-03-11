import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/employee_details_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/controller/task_controller.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class ProjectDashboard extends StatelessWidget {
  ProjectDashboard({super.key});

  final TaskController taskController = Get.put(TaskController());
  final int totalProjectCount = 10;

  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE ROW
                  Row(
                    children: [
                      const Text(
                        "Project Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      InkWell(
                        onTap: () {
                          Get.to(() => AddTask());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Overview · $formattedDate",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PROJECT COUNT
                  Text(
                    "$totalProjectCount total projects",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  const SizedBox(height: 10),

                  /// SEARCH
                  SizedBox(
                    height: 44,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search projects..",
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),

                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.12),

                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// PROJECT LIST
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                if (taskController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  );
                }

                if (taskController.tasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text("No project found"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: taskController.tasks.length,
                  padding: EdgeInsets.all(0),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text("Confirm Remove"),
                                    content: Text("Remove ${task.title} ?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text("Cancel"),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          if (task.id != null) {
                                            taskController.removeTask(task.id!);
                                          }
                                          Get.back();
                                        },
                                        child: const Text("Delete"),
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

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
