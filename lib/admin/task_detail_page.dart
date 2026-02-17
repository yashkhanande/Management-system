import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/employee_details_page.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/model/task.dart';

class TaskDetailPage extends StatelessWidget {
  TaskDetailPage({super.key});
  final _memberController = Get.find<MemberController>();
  @override
  Widget build(BuildContext context) {
    final Task task = Get.arguments;
    _memberController.getMemberById(task.ownerId);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          task.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ContainerDesign(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  if (_memberController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (_memberController.owner.value == null) {
                    return Text("No member assigned");
                  }
                  final member = _memberController.owner.value;

                  return ContainerDesign(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assigned to:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.off(
                            () => EmployeeDetailsPage(),
                            arguments: member,
                          ),
                          child: Text(
                            member!.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
