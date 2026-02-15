import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/container_design.dart';
import 'package:managementt/model/member.dart';

class EmployeeDetailsPage extends StatelessWidget {
  const EmployeeDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final Member member = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          member.name,
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
                      Text("Email : ${member.email ?? ""}"),
                      Text("Role : ${member.role ?? ""}"),
                      const SizedBox(height: 10),
                      ContainerDesign(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Task",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            member.tasks.isNotEmpty
                                ? ListView.builder(
                                    itemCount: member.tasks.length,
                                    itemBuilder: (context, index) {
                                      final taskId = member.tasks[index];
                                      // Here we have to fetch task so we can use task.title but idk how to get task from its id, we have taskId available and function is also created
                                      // return ListTile(title: TaskController.getTaskById(task).title) //- this is not working, idk why
                                      return ListTile(
                                        title: Text(taskId),
                                      ); // This is bugged, task is task's id (renamed task -> taskId)
                                    },
                                  )
                                : Text("No task for ${member.name}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
