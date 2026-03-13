import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';

class AddTask extends StatefulWidget {
  final String defaultType;
  final String? parentTaskId;

  const AddTask({super.key, this.defaultType = 'PROJECT', this.parentTaskId});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> with TickerProviderStateMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController memberSearchController = TextEditingController();
  final priorityController = ''.obs;
  final selectedMemberId = ''.obs;
  final memberSearchQuery = ''.obs;
  final Rx<DateTime?> selectedDeadline = Rx<DateTime?>(null);
  final TaskController _taskController = Get.find<TaskController>();
  final MemberController _memberController = Get.find<MemberController>();

  // Animation controllers
  late final AnimationController _bgController;
  late final AnimationController _staggerController;
  late final AnimationController _pulseController;
  late final AnimationController _orbController;

  // Staggered animations
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardSlide;
  // 7 items: title, description, type, priority, dates, member, button
  late final List<Animation<double>> _fieldFades;
  late final List<Animation<Offset>> _fieldSlides;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
          ),
        );
    _cardSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _fieldFades = List.generate(6, (i) {
      final start = 0.3 + (i * 0.08);
      final end = (start + 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _fieldSlides = List.generate(6, (i) {
      final start = 0.3 + (i * 0.08);
      final end = (start + 0.14).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _staggerController.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    AppColors.primary,
                    const Color(0xFF7C3AED),
                    _bgController.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF4338CA),
                    AppColors.primary,
                    _bgController.value,
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            ..._buildOrbs(),
            Column(
              children: [
                // Header
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 100, 28, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaleTransition(
                            scale: _pulseScale,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_task_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Create\nNew Task",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Assign work and set priorities for your team",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card form
                Expanded(
                  child: AnimatedBuilder(
                    animation: _cardSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _cardSlide.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            _animatedField(
                              0,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Task Title"),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: titleController,
                                    hint: "Enter task title",
                                    icon: Icons.title_rounded,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Description
                            _animatedField(
                              1,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Description"),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: descriptionController,
                                    hint: "Describe the task...",
                                    icon: Icons.description_outlined,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Priority
                            _animatedField(
                              2,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Priority"),
                                  const SizedBox(height: 8),
                                  Obx(
                                    () => Row(
                                      children: [
                                        _buildPriorityChip(
                                          "high",
                                          "High",
                                          Icons.bolt_rounded,
                                          color: AppColors.priorityHigh,
                                        ),
                                        const SizedBox(width: 10),
                                        _buildPriorityChip(
                                          "medium",
                                          "Medium",
                                          Icons.remove_circle_outline,
                                          color: AppColors.priorityMedium,
                                        ),
                                        const SizedBox(width: 10),
                                        _buildPriorityChip(
                                          "low",
                                          "Low",
                                          Icons.arrow_downward_rounded,
                                          color: AppColors.priorityLow,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Deadline
                            _animatedField(
                              3,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Deadline"),
                                  const SizedBox(height: 8),
                                  Obx(
                                    () => _buildDatePicker(
                                      label: "Pick Deadline",
                                      date: selectedDeadline.value,
                                      onTap: () => _pickDate(selectedDeadline),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Member selector
                            _animatedField(
                              4,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Assign To"),
                                  const SizedBox(height: 8),
                                  // Search bar
                                  TextField(
                                    controller: memberSearchController,
                                    onChanged: (v) => memberSearchQuery.value =
                                        v.trim().toLowerCase(),
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: "Search employees by name",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FC),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Obx(() {
                                    if (_memberController.members.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FC),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "No members available",
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    final query = memberSearchQuery.value;
                                    final filtered = query.isEmpty
                                        ? _memberController.members
                                        : _memberController.members
                                              .where(
                                                (m) => m.name
                                                    .toLowerCase()
                                                    .contains(query),
                                              )
                                              .toList();
                                    if (filtered.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "No employees match \"${memberSearchController.text}\"",
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: filtered
                                          .map(
                                            (m) => _buildMemberChip(
                                              m.id ?? '',
                                              m.name,
                                            ),
                                          )
                                          .toList(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Submit button
                            _animatedField(
                              5,
                              Obx(() {
                                if (_taskController.isLoading.value) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }
                                return _buildGradientButton();
                              }),
                            ),
                          ],
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
    );
  }

  Widget _animatedField(int index, Widget child) {
    return SlideTransition(
      position: _fieldSlides[index],
      child: FadeTransition(opacity: _fieldFades[index], child: child),
    );
  }

  List<Widget> _buildOrbs() {
    final orbs = <_OrbData>[
      _OrbData(size: 120, top: 60, right: -30, delay: 0.0),
      _OrbData(size: 80, top: 180, left: -20, delay: 0.3),
      _OrbData(size: 50, top: 120, right: 60, delay: 0.6),
      _OrbData(size: 90, top: 30, left: 80, delay: 0.5),
    ];
    return orbs.map((orb) {
      return AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final t = (_orbController.value + orb.delay) % 1.0;
          final yOff = math.sin(t * 2 * math.pi) * 18;
          final xOff = math.cos(t * 2 * math.pi) * 10;
          return Positioned(
            top: orb.top + yOff,
            left: orb.left != null ? orb.left! + xOff : null,
            right: orb.right != null ? orb.right! - xOff : null,
            child: child!,
          );
        },
        child: Container(
          width: orb.size,
          height: orb.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildGradientButton() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.lerp(
                  AppColors.primary,
                  const Color(0xFF7C3AED),
                  _bgController.value,
                )!,
                Color.lerp(
                  const Color(0xFF4338CA),
                  AppColors.primary,
                  _bgController.value,
                )!,
              ],
            ),
          ),
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_task_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  "Create Task",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    String value,
    String label,
    IconData icon, {
    required Color color,
  }) {
    final isSelected = priorityController.value == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: () => priorityController.value = value,
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color
                      : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icon,
                      key: ValueKey(isSelected),
                      size: 18,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: date != null ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? "${date.day}/${date.month}/${date.year}" : label,
                style: TextStyle(
                  fontSize: 13,
                  color: date != null
                      ? const Color(0xFF1F2937)
                      : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(Rx<DateTime?> target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: target.value ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      target.value = picked;
    }
  }

  Widget _buildMemberChip(String id, String name) {
    final isSelected = selectedMemberId.value == id;
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '?';
    return GestureDetector(
      onTap: () => selectedMemberId.value = id,
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedMemberId.value.isEmpty ||
        priorityController.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
      return;
    }
    await _taskController.addTask(
      Task(
        title: titleController.text,
        description: descriptionController.text,
        priority: priorityController.value,
        type: widget.defaultType,
        status: 'NOT_STARTED',
        ownerId: selectedMemberId.value,
        parentTaskId: widget.parentTaskId,
        deadLine: selectedDeadline.value,
        startDate: DateTime.now(),
      ),
    );
    await _memberController.getMembers();
    Get.back();
  }
}

class _OrbData {
  final double size;
  final double top;
  final double? left;
  final double? right;
  final double delay;

  const _OrbData({
    required this.size,
    required this.top,
    this.left,
    this.right,
    required this.delay,
  });
}
