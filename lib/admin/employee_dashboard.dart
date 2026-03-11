import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/register_employee.dart';
import 'package:managementt/admin/employee_details_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/controller/member_controller.dart';

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

class EmployeeDashboard extends StatelessWidget {
  EmployeeDashboard({super.key});

  final MemberController memberController = Get.put(MemberController());
  final int totalEmployeeCount = 10;

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
                        "Employee Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      InkWell(
                        onTap: () {
                          Get.to(() => RegisterEmployees());
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
                    "Team overview · $formattedDate",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// EMPLOYEE COUNT
                  Text(
                    "$totalEmployeeCount total employees",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  const SizedBox(height: 10),

                  /// SEARCH
                  SizedBox(
                    height: 44,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search employees..",
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

            /// EMPLOYEE LIST
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                if (memberController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  );
                }

                if (memberController.members.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text("No Members Found"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memberController.members.length,
                  padding: EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    final member = memberController.members[index];

                    return InkWell(
                      onTap: () {
                        Get.to(() => EmployeeDetailsPage(), arguments: member);
                      },

                      child: ContainerDesign(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              member.name,
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
                                    content: Text("Remove ${member.name} ?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text("Cancel"),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          if (member.id != null) {
                                            memberController.removeMember(
                                              member.id!,
                                            );
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
