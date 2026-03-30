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
    return Remark(
      id: json['id'],
      senderName: json['senderName'],
      senderId: json['senderId'],
      message: json['message'],
      timestamp: json['time'],
    );
  }
}
