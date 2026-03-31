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
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Collaboration',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Collaborations",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage your project links",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => AddCollaboration(), arguments: projectId);
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 List
            Expanded(
              child: Obx(() {
                final collaborators = collaborationController.collaborators;

                if (collaborators.isEmpty) {
                  return const Center(
                    child: Text(
                      "No collaborations yet 🚀",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: collaborators.length,
                  itemBuilder: (context, index) {
                    final collaborator = collaborators[index];

                    return GestureDetector(
                      onTap: () {
                        collaborationController.fetchAllProjects();
                        Get.to(() => ProjectDetailPage(project: collaborator));
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
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collaborator.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    collaborator.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                collaborationController.removeCollaborator(
                                  projectId ?? '',
                                  collaborator.id ?? '',
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
      ),
    );
  }
}
