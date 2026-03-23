class Task {
  String? id;
  String title;
  String description;
  String priority;
  String? type; // PROJECT or TASK
  String? status; // NOT_STARTED / TODO / DONE / OVERDUE
  String ownerId;
  String? parentTaskId;
  int progress; // 0-100
  int contributionPercent;
  String? remark;
  DateTime? deadLine;
  DateTime? startDate;
  int remainingTask;
  int completedTask;
  int? criticalDays;
  bool? isProject;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.type,
    this.status,
    required this.ownerId,
    this.parentTaskId,
    this.progress = 0,
    this.contributionPercent = 0,
    this.remark,
    this.deadLine,
    this.startDate,
    this.criticalDays,
    this.remainingTask = 0,
    this.completedTask = 0,
    this.isProject,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawDeadline = json['deadLine'] ?? json['deadline'];
    final rawStartDate = json['startDate'] ?? json['start_date'];
    final rawContribution =
        json['contributionPercent'] ??
        json['contribution'] ??
        json['contribution_percentage'];

    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      type: json['type'],
      status: json['status'],
      ownerId: json['ownerId'] ?? '',
      parentTaskId: json['parentTaskId'] ?? null,
      progress: json['progress'] ?? 0,
      contributionPercent: rawContribution is num
          ? rawContribution.toInt()
          : int.tryParse(rawContribution?.toString() ?? '') ?? 0,
      remark: json['remark'],
      deadLine: rawDeadline != null
          ? DateTime.tryParse(rawDeadline.toString())
          : null,
      startDate: rawStartDate != null
          ? DateTime.tryParse(rawStartDate.toString())
          : null,
      remainingTask: json['remainingTask'] ?? 0,
      completedTask: json['completedTask'] ?? 0,
      criticalDays: json['criticalDays'] != null
          ? (json['criticalDays'] is num
                ? json['criticalDays'].toInt()
                : int.tryParse(json['criticalDays'].toString()))
          : 7, //default 7 days
      isProject: json['isProject'] ?? false,
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
      "ownerId": ownerId,
      "parentTaskId": parentTaskId,
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
    };
  }
}
