import 'package:flutter/material.dart';
import 'package:managementt/components/app_colors.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.dashboard_outlined,
      Icons.assignment_outlined,
      Icons.check_box_outlined,
      Icons.bar_chart_outlined,
      Icons.person_outline,
    ];

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == 0;
          return Icon(
            items[index],
            size: 20,
            color: isSelected
                ? AppColors.primary
                : Colors.blueGrey.withValues(alpha: 0.6),
          );
        }),
      ),
    );
  }
}
