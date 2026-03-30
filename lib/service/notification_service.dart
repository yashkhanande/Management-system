import 'dart:convert';

import 'package:managementt/model/app_notification.dart';
import 'package:managementt/service/api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<List<AppNotification>> getNotifications(String memberId) async {
    final response = await _api.get('/members/notification/$memberId');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    }

    if (response.statusCode == 404) {
      // Some accounts (for example admin-only records) may have no member doc.
      return const <AppNotification>[];
    }

    throw Exception(
      response.body.isNotEmpty ? response.body : 'Failed to load notifications',
    );
  }

  
}
