import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/controller/admin_nav_controller.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/profile_controller.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final showProjects = false.obs;
  final isEditing = false.obs;
  final showPasswordSection = false.obs;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  @override
  void initState() {
    super.initState();
    final pc = Get.find<ProfileController>();
    nameController = TextEditingController(text: pc.memberName);
    phoneController = TextEditingController(
      text: pc.memberPhone == '-' ? '' : pc.memberPhone,
    );
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _syncControllersFromProfile(ProfileController pc) {
    if (!isEditing.value) {
      if (nameController.text != pc.memberName) {
        nameController.text = pc.memberName;
      }
      final phone = pc.memberPhone == '-' ? '' : pc.memberPhone;
      if (phoneController.text != phone) {
        phoneController.text = phone;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    final ac = Get.find<AuthController>();
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: AppRenderEntrance(
        child: Obx(() {
          _syncControllersFromProfile(pc);
          return SingleChildScrollView(
            child: Column(
              children: [
                // ─── Header ───
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + settings row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final nav = Get.find<AdminNavController>();
                              nav.changePage(0);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final confirm = await AppConfirmDialog.show(
                                title: 'Logout',
                                message: 'Are you sure you want to logout?',
                                cancelText: 'Stay',
                                confirmText: 'Logout',
                                tone: AppDialogTone.neutral,
                                icon: Icons.logout_rounded,
                              );

                              if (confirm == true) {
                                await ac.logout();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.logout,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Avatar + name row
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                pc.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pc.memberName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pc.memberRole,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    pc.memberRole,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ─── Contact info card ───
                _buildContactInfoCard(pc),
                const SizedBox(height: 16),
                // ─── Password change card ───
                _buildPasswordChangeCard(pc),
                const SizedBox(height: 16),

                // bottom padding for nav bar
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Contact Info Card with Edit Mode ───
  Widget _buildContactInfoCard(ProfileController pc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with edit button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                if (!isEditing.value)
                  GestureDetector(
                    onTap: () => isEditing.value = true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Email (not editable - shown as info)
            _InfoRow(
              icon: Icons.email_outlined,
              text: pc.memberEmail,
              iconColor: const Color(0xFF6366F1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Colors.grey.withValues(alpha: 0.15),
                height: 1,
              ),
            ),
            // Name (editable)
            if (isEditing.value) ...[
              _buildEditField(
                controller: nameController,
                label: 'Name',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _buildEditField(
                controller: phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // Save / Cancel buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        isEditing.value = false;
                        // Reset to original values
                        nameController.text = pc.memberName;
                        phoneController.text = pc.memberPhone == '-'
                            ? ''
                            : pc.memberPhone;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name is required',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade800,
                          );
                          return;
                        }
                        final success = await pc.updateProfile(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                        );
                        if (success) {
                          isEditing.value = false;
                          Get.snackbar(
                            'Success',
                            'Profile updated',
                            backgroundColor: Colors.green.shade100,
                            colorText: Colors.green.shade800,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to update profile',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade800,
                          );
                        }
                      },
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: pc.isSaving.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _InfoRow(
                icon: Icons.badge_outlined,
                text: pc.memberName,
                iconColor: const Color(0xFF6366F1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: Colors.grey.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                text: pc.memberPhone,
                iconColor: const Color(0xFF6366F1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  // ─── Password Change Card ───
  Widget _buildPasswordChangeCard(ProfileController pc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            // Header - always visible
            GestureDetector(
              onTap: () =>
                  showPasswordSection.value = !showPasswordSection.value,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.85),
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: showPasswordSection.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable content
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: showPasswordSection.value
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.grey.withValues(alpha: 0.15),
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: oldPasswordController,
                            label: 'Current Password',
                            obscure: obscureOld,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: newPasswordController,
                            label: 'New Password',
                            obscure: obscureNew,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            label: 'Confirm New Password',
                            obscure: obscureConfirm,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () async {
                                final old = oldPasswordController.text;
                                final newPwd = newPasswordController.text;
                                final confirm = confirmPasswordController.text;

                                if (old.isEmpty ||
                                    newPwd.isEmpty ||
                                    confirm.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'All fields are required',
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade800,
                                  );
                                  return;
                                }

                                if (newPwd.length < 6) {
                                  Get.snackbar(
                                    'Error',
                                    'New password must be at least 6 characters',
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade800,
                                  );
                                  return;
                                }

                                if (newPwd != confirm) {
                                  Get.snackbar(
                                    'Error',
                                    'Passwords do not match',
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade800,
                                  );
                                  return;
                                }

                                final error = await pc.changePassword(
                                  oldPassword: old,
                                  newPassword: newPwd,
                                );

                                if (error == null) {
                                  // Clear fields
                                  oldPasswordController.clear();
                                  newPasswordController.clear();
                                  confirmPasswordController.clear();
                                  showPasswordSection.value = false;
                                  Get.snackbar(
                                    'Success',
                                    'Password changed successfully',
                                    backgroundColor: Colors.green.shade100,
                                    colorText: Colors.green.shade800,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    error,
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade800,
                                  );
                                }
                              },
                              child: Obx(
                                () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: pc.isSaving.value
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Update Password',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required RxBool obscure,
  }) {
    return Obx(
      () => TextField(
        controller: controller,
        obscureText: obscure.value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF59E0B)),
          ),
          suffixIcon: GestureDetector(
            onTap: () => obscure.value = !obscure.value,
            child: Icon(
              obscure.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
      ),
    );
  }
}

// ─── Supporting widgets ───

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
