import 'dart:convert';

import 'package:managementt/model/category.dart';
import 'package:managementt/service/api_service.dart';

class CategoryService {
  final ApiService _api = ApiService();

  Exception _requestException(String fallback, dynamic body) {
    final text = body?.toString().trim() ?? '';
    return Exception(text.isNotEmpty ? text : fallback);
  }

  Future<List<Category>> getAllCategories() async {
    final response = await _api.get('/category/all');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const <Category>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(Category.fromJson)
          .toList();
    }

    final message = response.body.toLowerCase();
    if (message.contains('no categories present')) {
      return const <Category>[];
    }

    throw Exception(
      response.body.isNotEmpty ? response.body : 'Failed to load categories',
    );
  }

  Future<void> addCategory(String value) async {
    final response = await _api.post(
      '/category/add',
      body: {'category': value},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _requestException('Failed to add category', response.body);
    }
  }

  Future<void> updateCategory(String id, String value) async {
    final response = await _api.put('/category/update/$id', body: value);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _requestException('Failed to update category', response.body);
    }
  }

  Future<void> deleteCategory(String id) async {
    final response = await _api.delete('/category/delete/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _requestException('Failed to delete category', response.body);
    }
  }
}
