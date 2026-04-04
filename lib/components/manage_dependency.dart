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
                      "Manage Dependency",
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

              /// 🔹 Dependencies (Already Added)
              Obx(() {
                final dependencies = _collaborationController.dependencies();

                if (dependencies.isEmpty) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Added Dependencies",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      ...dependencies.map((depTask) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(depTask.title)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }),

              /// 🔹 Task List (Exclude Dependencies)
              Expanded(
                child: Obx(() {
                  if (_collaborationController.loadingTasks.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = _collaborationController.tasksOfCollaboration;

                  final dependencies = _collaborationController.dependencies();

                  /// 🔥 Create Set of dependency IDs for filtering
                  final dependencyIds = dependencies.map((e) => e.id).toSet();

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

                      /// 🔥 FILTER TASKS HERE
                      final tasks = entry.value
                          .where(
                            (t) =>
                                !dependencyIds.contains(t.id) && t.id != taskId,
                          ) // also remove self
                          .toList();

                      if (tasks.isEmpty) return const SizedBox();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Project Header
                            Row(
                              children: [
                                const Icon(
                                  Icons.folder,
                                  size: 18,
                                  color: Colors.blue,
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
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// Tasks
                            Column(
                              children: tasks.map((depTask) {
                                return InkWell(
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
                                        Expanded(child: Text(depTask.title)),
                                        const Icon(
                                          Icons.add_circle_outline,
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
            ],
          ),
        ),
      ),
    );
  }
}
