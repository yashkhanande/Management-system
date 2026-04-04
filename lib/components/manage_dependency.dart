import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_snackbar.dart';
import 'package:managementt/controller/collaboration_controller.dart';

class ManageDependency extends StatelessWidget {
  final String taskId;
  final String projectId;

  ManageDependency({super.key, required this.taskId, required this.projectId});

  final CollaborationController _collaborationController =
      Get.find<CollaborationController>();

  @override
  Widget build(BuildContext context) {
    _collaborationController.getAllTasksByCollaboration2(projectId, taskId);
    _collaborationController.getDependencies(taskId);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔹 Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Dependency",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              /// 🔹 Content
              Expanded(
                child: Obx(() {
                  if (_collaborationController.loadingTasks.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = _collaborationController.tasksOfCollaboration;

                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks available 🚀",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: data.entries.map((entry) {
                      final projectId = entry.key;
                      final tasks = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 Project Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.folder,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Project $projectId",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${tasks.length} tasks",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// 🔹 Tasks
                            Column(
                              children: tasks.map((depTask) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    _collaborationController.addDependency(
                                      taskId,
                                      depTask.id ?? '',
                                    );

                                    Get.back();

                                    AppSnackbar.show(
                                      "Success",
                                      "Dependency added",
                                      backgroundColor: Colors.black,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      borderRadius: 12,
                                      margin: const EdgeInsets.all(12),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.task_alt,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                depTask.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                depTask.description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
              Obx(() {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _collaborationController.dependencies().length,
                  itemBuilder: (context, index) {
                    final depTask = _collaborationController
                        .dependencies()[index];
                    return ListTile(
                      title: Text(depTask.title),
                      subtitle: Text(depTask.description),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
