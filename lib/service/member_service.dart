import 'dart:convert';

import 'package:managementt/config.dart';
import 'package:managementt/model/member.dart';
import 'package:http/http.dart' as http;

class MemberService {
  final String baseUrl = "${Config.baseUrl}/members";

  String _basicAuth() {
    String username = "yash"; // later you will take from login
    String password = "1234";

    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  Future<void> addMember(Member member) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _basicAuth(),
      },
      body: jsonEncode(member.toJson()),
    );
  }

  Future<List<Member>> getMembers() async {
    final responce = await http.get(
      Uri.parse("$baseUrl/all"),
     headers: {"Authorization": _basicAuth()},
    );

    if (responce.statusCode == 200) {
      List data = jsonDecode(responce.body);
      return data.map((e) => Member.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Members");
    }
  }

  Future<void> removeMember(String id) async {
    await http.delete(
      Uri.parse("$baseUrl/delete/$id"),
      headers: {'Authorization': _basicAuth()},
    );
  }

  Future<Member> getMemberById(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/id/$id"),
      headers: {"Authorization": _basicAuth()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception("Failed to load Member");
    }
  }
}
