import 'package:flutter/material.dart';
import 'package:managementt/components/animated_gradient_container.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/section_header.dart';
import 'package:managementt/components/stat_card.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: AppColors.primary),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AnimatedGradientContainer(
                height: 220,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Text(
                      "Matthew Agrawal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const Text(
                      "Sunday, 22 Jan 2026",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: StatCard(
                            icon: Icons.folder_open,
                            count: '0',
                            label: 'Projects',
                            iconColor: Color(0xFFF3B200),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.edit_note,
                            count: '0',
                            label: 'Active',
                            iconColor: Color(0xFF60A5FA),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.task_alt,
                            count: '0',
                            label: 'Tasks',
                            iconColor: Color(0xFF4ADE80),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.warning_amber_rounded,
                            count: '0',
                            label: 'Overdue',
                            iconColor: Color(0xFFFACC15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Task overview placeholder
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        "Task Overview - Coming Soon",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Active Tasks', actionText: 'See all'),
              const SectionHeader(
                title: 'Upcoming Deadlines',
                actionText: 'See all',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
