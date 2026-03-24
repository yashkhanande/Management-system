import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/category_controller.dart';
import 'package:managementt/controller/task_controller.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final TaskController _taskController = Get.find<TaskController>();

  Future<void> _showUpsertDialog({String? oldValue}) async {
    final isEdit = oldValue != null;
    final controller = TextEditingController(text: oldValue ?? '');

    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Modify Category' : 'Add Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Enter category',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text;
              final ok = isEdit
                  ? await _categoryController.updateCategory(oldValue, value)
                  : await _categoryController.addCategory(value);
              if (!ok) {
                Get.snackbar(
                  'Category not saved',
                  'It may be empty or already exists.',
                  backgroundColor: AppColors.warning,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back(result: true);
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      Get.snackbar(
        'Success',
        isEdit ? 'Category updated.' : 'Category added.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteCategory(String value) async {
    final normalized = value.trim().toUpperCase();
    final inUseCount = _taskController.projects.where((project) {
      final projectCategory = (project.category ?? '').trim().toUpperCase();
      return projectCategory == normalized;
    }).length;

    if (inUseCount > 0) {
      Get.snackbar(
        'Delete blocked',
        'This category is used by $inUseCount project(s). Reassign those projects first.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    final confirm = await AppConfirmDialog.show(
      title: 'Delete Category',
      message: 'Remove "$value" from categories?',
      confirmText: 'Delete',
    );

    if (!confirm) return;

    final ok = await _categoryController.deleteCategory(value);
    if (!ok) {
      Get.snackbar(
        'Delete failed',
        'Could not remove category. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Deleted',
      'Category removed successfully.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Obx(() {
        final categories = _categoryController.categories;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Use categories to organize projects.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showUpsertDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: categories.isEmpty
                  ? const Center(
                      child: Text(
                        'No categories yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _showUpsertDialog(oldValue: category),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                tooltip: 'Modify',
                              ),
                              IconButton(
                                onPressed: () => _deleteCategory(category),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
