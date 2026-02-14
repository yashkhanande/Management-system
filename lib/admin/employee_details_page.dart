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
                    children: [Text("Employee details page")],
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
