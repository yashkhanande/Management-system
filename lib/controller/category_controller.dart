import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _categoriesStorageKey = 'project_categories';

  static const List<String> _defaultCategories = [
    'FINANCE',
    'BUSSINESS',
    'SOMETHING1',
    'SOMETHING2',
  ];

  final RxList<String> categories = <String>[..._defaultCategories].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  List<String> get dropdownOptions => ['ALL', ...categories];

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final raw = await _storage.read(key: _categoriesStorageKey);
      if (raw == null || raw.trim().isEmpty) {
        categories.assignAll(_defaultCategories);
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final values = _normalizeAll(decoded.map((e) => e.toString()));
        if (values.isEmpty) {
          categories.assignAll(_defaultCategories);
        } else {
          categories.assignAll(values);
        }
      } else {
        categories.assignAll(_defaultCategories);
      }
    } catch (_) {
      categories.assignAll(_defaultCategories);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _persist() async {
    await _storage.write(
      key: _categoriesStorageKey,
      value: jsonEncode(categories),
    );
  }

  String _normalizeOne(String value) {
    return value.trim().toUpperCase();
  }

  List<String> _normalizeAll(Iterable<String> values) {
    final result = <String>[];
    for (final raw in values) {
      final normalized = _normalizeOne(raw);
      if (normalized.isNotEmpty && !result.contains(normalized)) {
        result.add(normalized);
      }
    }
    return result;
  }

  Future<bool> addCategory(String value) async {
    final normalized = _normalizeOne(value);
    if (normalized.isEmpty) return false;
    if (categories.contains(normalized)) return false;

    categories.add(normalized);
    await _persist();
    return true;
  }

  Future<bool> updateCategory(String oldValue, String newValue) async {
    final normalizedOld = _normalizeOne(oldValue);
    final normalizedNew = _normalizeOne(newValue);

    if (normalizedOld.isEmpty || normalizedNew.isEmpty) return false;

    final idx = categories.indexOf(normalizedOld);
    if (idx < 0) return false;

    final conflictIndex = categories.indexOf(normalizedNew);
    if (conflictIndex >= 0 && conflictIndex != idx) return false;

    categories[idx] = normalizedNew;
    categories.refresh();
    await _persist();
    return true;
  }

  Future<bool> deleteCategory(String value) async {
    final normalized = _normalizeOne(value);
    if (normalized.isEmpty) return false;

    final removed = categories.remove(normalized);
    if (!removed) return false;

    await _persist();
    return true;
  }
}
