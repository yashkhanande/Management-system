class Remark {
  final String id;
  final String? senderName;
  final String senderId;
  final String message;
  final String timestamp;

  Remark({
    required this.id,
    this.senderName,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'senderId': senderId,
      'message': message,
      'time': timestamp,
    };
  }

  factory Remark.fromJson(Map<String, dynamic> json) {
    final dynamic rawTimestamp =
        json['time'] ?? json['timestamp'] ?? json['createdAt'];

    return Remark(
      id: (json['id'] ?? '').toString(),
      senderName: json['senderName']?.toString(),
      senderId: (json['senderId'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      timestamp: rawTimestamp?.toString() ?? '',
    );
  }
}
