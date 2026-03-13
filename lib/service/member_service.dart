import 'dart:convert';
import 'package:managementt/model/member.dart';
import 'package:managementt/service/api_service.dart';

class MemberService {
  final ApiService _api = ApiService();

  Future<void> addMember(Member member) async {
    final response = await _api.post('/members', body: member.toJson());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to add member',
      );
    }
  }

  Future<List<Member>> getMembers() async {
    final response = await _api.get('/members/all');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Member.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Members');
    }
  }

  Future<void> removeMember(String id) async {
    final response = await _api.delete('/members/delete/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to remove member',
      );
    }
  }

  Future<Member> getMemberById(String id) async {
    final response = await _api.get('/members/id/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception('Failed to load Member');
    }
  }

  Future<int> getTaskCount(String ownerId) async {
    final response = await _api.get('/members/taskCount/$ownerId');
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    } else {
      throw Exception('Failed to get task count');
    }
  }

  Future<int> getStatusCount(String ownerId, String status) async {
    final response = await _api.get('/members/$ownerId/projects/$status/count');
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    } else {
      throw Exception('Failed to get status count');
    }
  }
}
