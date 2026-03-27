import 'package:flutter/material.dart';
import 'package:managementt/components/app_colors.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? dueText;
  final String? status;
  final double progress;
  final double? timeProgress;
  final String progressLabel;
  final String timeLabel;
  final List<String> teamMembers;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ProjectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.dueText,
    this.status,
    this.progress = 0.55,
    this.timeProgress,
    this.progressLabel = 'Project Progress',
    this.timeLabel = 'Time Remaining',
    this.teamMembers = const ['A', 'R', 'K'],
    this.accentColor = const Color(0xFF2F59F7),
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final normalizedTimeProgress = timeProgress?.clamp(0.0, 1.0);
    final visibleMembers = teamMembers.take(4).toList();
    final avatarStackWidth = visibleMembers.isEmpty
        ? 0.0
        : 26 + ((visibleMembers.length - 1) * 14.0);

    final avatarColors = [
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        width: MediaQuery.widthOf(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dueText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEF0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dueText!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFF4D57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ProgressTrack(
              label: progressLabel,
              value: normalizedProgress,
              color: accentColor,
            ),
            if (normalizedTimeProgress != null) ...[
              const SizedBox(height: 6),
              _ProgressTrack(
                label: timeLabel,
                value: normalizedTimeProgress,
                color: const Color(0xFFF59E0B),
                backgroundColor: const Color(0xFFFFF1D6),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: avatarStackWidth,
                      height: 24,
                      child: Stack(
                        children: List.generate(visibleMembers.length, (index) {
                          return Positioned(
                            left: index * 14,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    avatarColors[index % avatarColors.length],
                                child: Text(
                                  visibleMembers[index].isEmpty
                                      ? '?'
                                      : visibleMembers[index][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status ?? '0/0 tasks',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.blueGrey.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(normalizedProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _ProgressTrack extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final Color backgroundColor;

  const _ProgressTrack({
    required this.label,
    required this.value,
    required this.color,
    this.backgroundColor = const Color(0xFFE8EAF7),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.withValues(alpha: 0.9),
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          minHeight: 4,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
