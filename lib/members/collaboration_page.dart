import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/add_collaboration.dart';
import 'package:managementt/controller/collaboration_controller.dart';

class CollaborationPage extends StatelessWidget {
  CollaborationPage({super.key});
  final collaborationController = Get.put(CollaborationController());
  final projectId = Get.arguments;

  @override
  Widget build(BuildContext context) {
    collaborationController.getCollaboratedProjects(projectId);
    return Scaffold(
      appBar: AppBar(title: const Text('Collaboration')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Add Collaboration with a Project"),
            ElevatedButton(
              onPressed: () {
                Get.to(() => AddCollaboration(), arguments: projectId);
              },
              child: const Text('Add Collaborator'),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (collaborationController.collaborators.isEmpty) {
                return const Text("No collaborators found");
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: collaborationController.collaborators.length,
                itemBuilder: (context, index) {
                  final collaborator =
                      collaborationController.collaborators[index];
                  return ListTile(
                    title: Text(collaborator.title),
                    subtitle: Text(collaborator.description),
                    onTap: () => Get.to(() => ProjectDetailPage(project: collaborator,)),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
