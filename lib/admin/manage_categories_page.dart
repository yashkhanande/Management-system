import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
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
    final result = await Get.dialog<bool>(
      _CategoryUpsertDialog(
        isEdit: isEdit,
        initialValue: oldValue ?? '',
        onSubmit: (value) async {
          final ok = isEdit
              ? await _categoryController.updateCategory(oldValue!, value)
              : await _categoryController.addCategory(value);

          if (ok) return null;

          final details = _categoryController.lastError.value.trim();
          return details.isEmpty
              ? 'Category could not be saved. It may be empty or already exists.'
              : details;
        },
      ),
      barrierDismissible: true,
      transitionCurve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 230),
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
    final normalized = value.trim().toLowerCase();
    final inUseCount = _taskController.projects.where((project) {
      final projectCategory = (project.category ?? '').trim().toLowerCase();
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
      tone: AppDialogTone.danger,
      icon: Icons.delete_outline_rounded,
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: Obx(() {
          final categories = [..._categoryController.categories]
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          final isLoading = _categoryController.isLoading.value;
          final loadError = _categoryController.lastError.value.trim();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHero(
                  context,
                  topPadding: topPadding,
                  categoryCount: categories.length,
                ),
              ),
              if (isLoading && categories.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (loadError.isNotEmpty && categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildStateCard(
                    icon: Icons.cloud_off_rounded,
                    title: 'Could not load categories',
                    message: loadError,
                    actionText: 'Try Again',
                    onActionTap: _categoryController.loadCategories,
                  ),
                )
              else if (categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildStateCard(
                    icon: Icons.category_outlined,
                    title: 'No categories yet',
                    message:
                        'Create your first category to organize projects by domain, team, or workflow.',
                    actionText: 'Add Category',
                    onActionTap: () => _showUpsertDialog(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == categories.length - 1 ? 0 : 10,
                        ),
                        child: _buildCategoryTile(
                          category: category,
                          index: index,
                        ),
                      );
                    }, childCount: categories.length),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context, {
    required double topPadding,
    required int categoryCount,
  }) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, topPadding + 12, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canPop)
                _buildHeaderButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onTap: () => Get.back(),
                ),
              if (canPop) const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Workspace',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showUpsertDialog(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroChip(
                icon: Icons.category_rounded,
                label: '$categoryCount categories',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: Text(
                  actionText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({required String category, required int index}) {
    final trimmed = category.trim();
    final display = trimmed.isEmpty ? category : trimmed;
    final initial = display.isEmpty
        ? '?'
        : display.substring(0, 1).toUpperCase();
    final accent =
        AppColors.avatarColors[index % AppColors.avatarColors.length];
    final delayIndex = index > 8 ? 8 : index;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 220 + (delayIndex * 40)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                display,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _buildActionButton(
              icon: Icons.edit_rounded,
              tooltip: 'Modify',
              color: AppColors.primary,
              onTap: () => _showUpsertDialog(oldValue: display),
            ),
            const SizedBox(width: 6),
            _buildActionButton(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Delete',
              color: AppColors.error,
              onTap: () => _deleteCategory(display),
            ),
          ],
        ),
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, color: color, size: 19),
          ),
        ),
      ),
    );
  }
}

class _CategoryUpsertDialog extends StatefulWidget {
  final bool isEdit;
  final String initialValue;
  final Future<String?> Function(String value) onSubmit;

  const _CategoryUpsertDialog({
    required this.isEdit,
    required this.initialValue,
    required this.onSubmit,
  });

  @override
  State<_CategoryUpsertDialog> createState() => _CategoryUpsertDialogState();
}

class _CategoryUpsertDialogState extends State<_CategoryUpsertDialog> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorText = '';
    });

    final error = await widget.onSubmit(_controller.text.trim());
    if (!mounted) return;

    if (error == null || error.trim().isEmpty) {
      Get.back(result: true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.92, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: ((value - 0.92) / 0.08).clamp(0, 1),
              child: Transform.scale(scale: value, child: child),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 32,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.isEdit
                              ? Icons.edit_note_rounded
                              : Icons.add_circle_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isEdit
                              ? 'Update Category'
                              : 'Add New Category',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          hintText: 'Example: Development, QA, Operations',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeOut,
                        child: _errorText.isEmpty
                            ? const SizedBox(height: 12)
                            : Padding(
                                key: ValueKey<String>(_errorText),
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _errorText,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Get.back(result: false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 170),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        key: const ValueKey('label'),
                                        widget.isEdit
                                            ? 'Save Changes'
                                            : 'Add Category',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
