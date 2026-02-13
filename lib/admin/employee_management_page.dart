import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_employee.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/controller/member_controller.dart';

class EmployeeManagementPage extends StatelessWidget {
  EmployeeManagementPage({super.key});
  final MemberController memberController = Get.put(MemberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              "Employees",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                // Example add member
                Get.to(() => AddEmployee());
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey.withValues(alpha: 0.2),
                ),
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Obx(() {
            if (memberController.members.isEmpty) {
              return Center(child: Text("No Members Found"));
            }

            return ListView.builder(
              itemCount: memberController.members.length,
              itemBuilder: (context, index) {
                final member = memberController.members[index];

                return ContainerDesign(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        member.name,
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
                                "Are you sure you want to remove ${member.name} ?",
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
                                    if (member.id != null) {
                                      memberController.removeMember(member.id!);
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
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
