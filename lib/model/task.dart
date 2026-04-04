class Task {
  String? id;
  String title;
  String description;
  String priority;
  String? type; // PROJECT or TASK
  String? status; // NOT_STARTED / TODO / DONE / OVERDUE
  String? category;
  String ownerId;
  String? parentId;
  int progress; // 0-100
  int contributionPercent;
  String? remark;
  DateTime? deadLine;
  DateTime? startDate;
  int remainingTask;
  int completedTask;
  int? criticalDays;
  bool? isProject;
  List<String>? collaborators;
  List<String>? dependentTasks;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.type,
    this.status,
    this.category,
    required this.ownerId,
    this.parentId,
    this.progress = 0,
    this.contributionPercent = 0,
    this.remark,
    this.deadLine,
    this.startDate,
    this.criticalDays,
    this.remainingTask = 0,
    this.completedTask = 0,
    this.isProject,
    this.collaborators,
    this.dependentTasks,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawDeadline = json['deadLine'] ?? json['deadline'];
    final rawStartDate = json['startDate'] ?? json['start_date'];
    final rawContribution =
        json['contributionPercent'] ??
        json['contribution'] ??
        json['contribution_percentage'];
    final type = (json['type'] ?? '').toString().trim().toUpperCase();
    final rawStatus = (json['status'] ?? '').toString().trim().toUpperCase();
    final deadline = rawDeadline != null
        ? DateTime.tryParse(rawDeadline.toString())
        : null;
    final progressValue = (json['progress'] ?? 0) is num
        ? (json['progress'] as num).toInt()
        : int.tryParse((json['progress'] ?? 0).toString()) ?? 0;
    final completedTaskValue = (json['completedTask'] ?? 0) is num
        ? (json['completedTask'] as num).toInt()
        : int.tryParse((json['completedTask'] ?? 0).toString()) ?? 0;
    final normalizedStatus = (() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final deadlineDate = deadline == null
          ? null
          : DateTime(deadline.year, deadline.month, deadline.day);
      final isOverdue = deadlineDate != null && deadlineDate.isBefore(today);

      if (type == 'TASK') {
        if (rawStatus == 'DONE' || rawStatus == 'COMPLETED') return 'DONE';
        if (isOverdue) return 'OVERDUE';
        if (rawStatus == 'REVIEW') return 'REVIEW';
        return 'IN_PROGRESS';
      }

      if (progressValue >= 100) return 'DONE';
      if (isOverdue) return 'OVERDUE';
      if (completedTaskValue == 0) return 'NOT_STARTED';
      return 'IN_PROGRESS';
    })();

    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      type: json['type'],
      status: normalizedStatus,
      category: json['category'] ?? json['projectCategory'],
      ownerId: json['ownerId'] ?? '',
      parentId: json['parentId'] ?? null,
      progress: progressValue,
      contributionPercent: rawContribution is num
          ? rawContribution.toInt()
          : int.tryParse(rawContribution?.toString() ?? '') ?? 0,
      remark: json['remark'],
      deadLine: deadline,
      startDate: rawStartDate != null
          ? DateTime.tryParse(rawStartDate.toString())
          : null,
      remainingTask: (json['remainingTask'] ?? 0) is num
          ? (json['remainingTask'] as num).toInt()
          : int.tryParse((json['remainingTask'] ?? 0).toString()) ?? 0,
      completedTask: completedTaskValue,
      criticalDays: json['criticalDays'] != null
          ? (json['criticalDays'] is num
                ? json['criticalDays'].toInt()
                : int.tryParse(json['criticalDays'].toString()))
          : 7, //default 7 days
      isProject: json['isProject'] ?? false,
      collaborators: json['collaborators'] != null
          ? List<String>.from(json['collaborators'])
          : null,
      dependentTasks: json['dependentTasks'] != null
          ? List<String>.from(json['dependentTasks'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final deadlineValue = deadLine?.toIso8601String().split('T').first;
    final startDateValue = startDate?.toIso8601String().split('T').first;

    return {
      "id": id,
      "title": title,
      "description": description,
      "priority": priority,
      "type": type,
      "status": status,
      "category": category,
      "ownerId": ownerId,
      "parentId": parentId,
      "progress": progress,
      "contributionPercent": contributionPercent,
      "contribution": contributionPercent,
      "remark": remark,
      // Send both keys to stay compatible with current and legacy backend field names.
      "deadline": deadlineValue,
      "deadLine": deadlineValue,
      "startDate": startDateValue,
      "remainingTask": remainingTask,
      "completedTask": completedTask,
      "criticalDays": criticalDays ?? 7,
      "isProject": isProject ?? false,
      "collaborators": collaborators,
      "dependentTasks": dependentTasks,
    };
  }
}
