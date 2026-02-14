class Member {
  String? id;
  String name;
  String? email;
  int? mobileNo;
  String? role;
  List<String> tasks;

  Member({
    this.id,
    required this.name,
    required this.tasks,
    this.email,
    this.mobileNo,
    this.role,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      role: json['role'],
      tasks: List<String>.from(json['tasks'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "mobileNo": mobileNo,
      "role": role,
      "tasks": tasks,
    };
  }
}
