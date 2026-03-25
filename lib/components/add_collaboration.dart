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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Collaboration')),
      body: Column(
        children: [
          Obx(() {
            final projects = collaborationController.projects;
            return ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  title: Text(project.title),
                  subtitle: Text('Owner: ${project.ownerId}'),
                  onTap: () {
                    collaborationController.addCollaborator(projectId,project.id ?? '');
                    Get.back();
                  },
                );
              },
              itemCount: collaborationController.projects.length,
            );
          }),
        ],
      ),
    );
  }
}
