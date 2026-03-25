import 'package:get/get.dart';
import 'package:managementt/model/category.dart';
import 'package:managementt/service/category_service.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = CategoryService();
  final Map<String, String> _categoryIdByValue = <String, String>{};

  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  List<String> get dropdownOptions => ['ALL', ...categories];

  Future<void> loadCategories() async {
    isLoading.value = true;
    lastError.value = '';
    try {
      final fromApi = await _categoryService.getAllCategories();
      _categoryIdByValue
        ..clear()
        ..addAll(_extractIdMapping(fromApi));
      categories.assignAll(_normalizeAll(fromApi.map((item) => item.category)));
    } catch (e) {
      categories.clear();
      _categoryIdByValue.clear();
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizeOne(String value) {
    return value.trim();
  }

  String _canonical(String value) {
    return value.trim().toLowerCase();
  }

  List<String> _normalizeAll(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};
    for (final raw in values) {
      final normalized = _normalizeOne(raw);
      final key = _canonical(normalized);
      if (normalized.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        result.add(normalized);
      }
    }
    return result;
  }

  Map<String, String> _extractIdMapping(List<Category> values) {
    final result = <String, String>{};
    for (final item in values) {
      final normalized = _normalizeOne(item.category);
      final key = _canonical(normalized);
      final id = item.id?.trim();
      if (key.isNotEmpty && id != null && id.isNotEmpty) {
        result[key] = id;
      }
    }
    return result;
  }

  Future<bool> addCategory(String value) async {
    lastError.value = '';
    final normalized = _normalizeOne(value);
    final canonical = _canonical(value);
    if (normalized.isEmpty) {
      lastError.value = 'Category cannot be empty.';
      return false;
    }
    if (categories.any((item) => _canonical(item) == canonical)) {
      lastError.value = 'Category already exists.';
      return false;
    }

    try {
      await _categoryService.addCategory(normalized);
      if (!categories.any((item) => _canonical(item) == canonical)) {
        categories.add(normalized);
      }
      try {
        await loadCategories();
      } catch (_) {
        // Keep local value when refresh fails after successful insert.
      }
      return true;
    } catch (e) {
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    }
  }

  Future<bool> updateCategory(String oldValue, String newValue) async {
    lastError.value = '';
    final normalizedOld = _normalizeOne(oldValue);
    final normalizedNew = _normalizeOne(newValue);
    final canonicalOld = _canonical(oldValue);
    final canonicalNew = _canonical(newValue);

    if (normalizedOld.isEmpty || normalizedNew.isEmpty) {
      lastError.value = 'Category cannot be empty.';
      return false;
    }

    final idx = categories.indexWhere(
      (item) => _canonical(item) == canonicalOld,
    );
    if (idx < 0) {
      lastError.value = 'Category not found.';
      return false;
    }

    final conflictIndex = categories.indexWhere(
      (item) => _canonical(item) == canonicalNew,
    );
    if (conflictIndex >= 0 && conflictIndex != idx) {
      lastError.value = 'Category already exists.';
      return false;
    }

    final id = _categoryIdByValue[canonicalOld];
    if (id == null || id.isEmpty) {
      lastError.value = 'Category id not available. Refresh and retry.';
      return false;
    }

    try {
      await _categoryService.updateCategory(id, normalizedNew);
      categories[idx] = normalizedNew;
      categories.refresh();
      _categoryIdByValue.remove(canonicalOld);
      _categoryIdByValue[canonicalNew] = id;
      return true;
    } catch (e) {
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    }
  }

  Future<bool> deleteCategory(String value) async {
    lastError.value = '';
    final normalized = _normalizeOne(value);
    final canonical = _canonical(value);
    if (normalized.isEmpty) {
      lastError.value = 'Category cannot be empty.';
      return false;
    }

    final id = _categoryIdByValue[canonical];
    if (id == null || id.isEmpty) {
      lastError.value = 'Category id not available. Refresh and retry.';
      return false;
    }

    try {
      await _categoryService.deleteCategory(id);
    } catch (e) {
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    }

    final removeIndex = categories.indexWhere(
      (item) => _canonical(item) == canonical,
    );
    if (removeIndex < 0) {
      lastError.value = 'Category not found.';
      return false;
    }
    categories.removeAt(removeIndex);

    _categoryIdByValue.remove(canonical);
    return true;
  }
}
