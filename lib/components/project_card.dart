import 'package:flutter/material.dart';
import 'package:managementt/components/app_colors.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String? status;
  final double progress;
  final List<String> teamMembers;
  final VoidCallback? onTap;
  const ProjectCard({
    super.key,
    required this.title,
    this.status,
    this.progress = 0.55,
    this.teamMembers = const ['A', 'R', 'K'],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final visibleMembers = teamMembers.take(4).toList();
    final avatarStackWidth = visibleMembers.isEmpty
        ? 0.0
        : 28 + ((visibleMembers.length - 1) * 18.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        width: MediaQuery.widthOf(context),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: normalizedProgress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(223, 57, 27, 255),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    status ?? '${(normalizedProgress * 100).toStringAsFixed(0)}% complete',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: avatarStackWidth,
                  height: 28,
                  child: Stack(
                    children: List.generate(visibleMembers.length, (index) {
                      return Positioned(
                        left: index * 18,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color.fromARGB(255, 135, 111, 231),
                            child: Text(
                              visibleMembers[index].isEmpty
                                  ? '?'
                                  : visibleMembers[index][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        )
                      );
                    }),
                  ),
                ),
              ],
            ),
            if (teamMembers.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${teamMembers.length - 4} more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.withValues(alpha: 0.9),
                  ),
                ),
              ),
          ],
        ),
        ),
      );
  }
}
