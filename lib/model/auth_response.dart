class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String? userId;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      role: json['role'],
      // Backend may send this as userId or id.
      // Keep it flexible to avoid breaking when backend field names differ.
      userId: (json['userId'] ?? json['id'] ?? json['memberId'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "role": role,
      if (userId != null) "userId": userId,
    };
  }
}
