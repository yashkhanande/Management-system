import 'package:flutter/material.dart';

class StatusData {
  final String label;
  final int count;
  final Color color;

  const StatusData({
    required this.label,
    required this.count,
    required this.color,
  });
}

class AlertItem {
  final String title;
  final String subtitle;

  const AlertItem({required this.title, required this.subtitle});
}

class DeadlineItem {
  final String title;
  final String subtitle;
  final String due;
  final Color accent;
  final String initials;

  const DeadlineItem({
    required this.title,
    required this.subtitle,
    required this.due,
    required this.accent,
    required this.initials,
  });
}

class TeamMemberItem {
  final String name;
  final String tasks;
  final String initials;

  const TeamMemberItem({
    required this.name,
    required this.tasks,
    required this.initials,
  });
}

class ActivityItem {
  final String initials;
  final String message;
  final String project;
  final String when;

  const ActivityItem({
    required this.initials,
    required this.message,
    required this.project,
    required this.when,
  });
}
