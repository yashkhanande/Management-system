import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/controller/collaboration_controller.dart';
import 'package:managementt/controller/task_controller.dart';

class AddCollaboration extends StatelessWidget {
  AddCollaboration({super.key});

  final TaskController taskController = Get.find<TaskController>();
  final CollaborationController collaborationController =
      Get.find<CollaborationController>();

  final projectId = Get.arguments;

  @override
  Widget build(BuildContext context) {
    collaborationController.fetchAllProjects();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Collaboration',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (collaborationController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = collaborationController.projects;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

              return GestureDetector(
                onTap: () {
                  collaborationController.addCollaborator(
                    projectId,
                    project.id ?? '',
                  );
                  collaborationController.getCollaboratedProjects(projectId!);

                  collaborationController.getAllTasksByCollaboration(
                    projectId!,
                  );

                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Icon(Icons.work, color: Colors.blue),
                      ),

                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Owner: ${project.ownerId}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.add_circle_outline, color: Colors.blue),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
