import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'Add Collaboration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (collaborationController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final projects = collaborationController.projects;
          final currentProjectId = projectId?.toString() ?? '';
          final collaboratorIds = collaborationController.collaborators
              .map((c) => c.id ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();

          final filteredProjects = projects.where((p) {
            final pid = p.id ?? '';
            if (pid.isEmpty) return false;
            if (pid == currentProjectId) return false;
            if (collaboratorIds.contains(pid)) return false;
            return true;
          }).toList();

          if (filteredProjects.isEmpty) {
            return const Center(
              child: Text(
                'No available projects to add',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];

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
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(Icons.work, color: AppColors.primary),
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
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.alertTitle,
                      ),
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
