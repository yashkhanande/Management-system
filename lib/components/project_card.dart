import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String? status;
  final VoidCallback? onTap;
  const ProjectCard({super.key, required this.title, this.status, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        padding: EdgeInsets.all(10),
        width: MediaQuery.widthOf(context),
        decoration: BoxDecoration(
          color: status == "On schedule"
              ? Colors.greenAccent.withValues(alpha: 0.9)
              : status == "late"
              ? Colors.redAccent
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.borderColor,
              ),
              child: Text(
                status ?? "no update",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
