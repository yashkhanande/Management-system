import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_snackbar.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/model/member.dart';

class RegisterEmployees extends StatefulWidget {
  const RegisterEmployees({super.key});

  @override
  State<RegisterEmployees> createState() => _RegisterEmployeesState();
}

class _RegisterEmployeesState extends State<RegisterEmployees>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final roleController = ''.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final MemberController memberController = Get.find<MemberController>();
  final _obscurePassword = true.obs;

  // Animation controllers
  late final AnimationController _bgController;
  late final AnimationController _staggerController;
  late final AnimationController _pulseController;
  late final AnimationController _orbController;

  // Staggered animations
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardSlide;
  late final List<Animation<double>> _fieldFades;
  late final List<Animation<Offset>> _fieldSlides;

  // Pulse
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Background gradient animation — loops forever
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Floating orbs
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Staggered entrance
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

    // 5 fields: name, email, password, role, button
    _fieldFades = List.generate(5, (i) {
      final start = 0.3 + (i * 0.12);
      final end = (start + 0.18).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _fieldSlides = List.generate(5, (i) {
      final start = 0.3 + (i * 0.12);
      final end = (start + 0.18).clamp(0.0, 1.0);
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

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Kick off entrance
    _staggerController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _staggerController.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
                    AppColors.alertTitle,
                    _bgController.value,
                  )!,
                  Color.lerp(
                    AppColors.alertTitle,
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
            // Floating orbs
            ..._buildOrbs(),

            // Main content
            Column(
              children: [
                // Header area
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 100, 28, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pulsing icon
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
                                Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Register\nNew Employee",
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
                            "Fill in the details below to add a team member",
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
                            // Name
                            _animatedField(
                              0,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Full Name"),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: nameController,
                                    hint: "Enter full name",
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Email
                            _animatedField(
                              1,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Email Address"),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: emailController,
                                    hint: "Enter email address",
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password
                            _animatedField(
                              2,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Password"),
                                  const SizedBox(height: 8),
                                  Obx(
                                    () => _buildTextField(
                                      controller: passwordController,
                                      hint: "Enter password",
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword.value,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword.value
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.textSecondary,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _obscurePassword.value =
                                                !_obscurePassword.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Role
                            _animatedField(
                              3,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Role"),
                                  const SizedBox(height: 8),
                                  Obx(
                                    () => Row(
                                      children: [
                                        _buildRoleChip(
                                          "USER",
                                          "Member",
                                          Icons.person_outline,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildRoleChip(
                                          "ADMIN",
                                          "Admin",
                                          Icons.shield_outlined,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Submit button
                            _animatedField(
                              4,
                              Obx(() {
                                if (memberController.isLoading.value) {
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

  // -- Animated field wrapper --
  Widget _animatedField(int index, Widget child) {
    return SlideTransition(
      position: _fieldSlides[index],
      child: FadeTransition(opacity: _fieldFades[index], child: child),
    );
  }

  // -- Floating orbs in the background --
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

  // -- Gradient button (shifts like the background) --
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
                  AppColors.alertTitle,
                  _bgController.value,
                )!,
                Color.lerp(
                  AppColors.alertTitle,
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
                Icon(Icons.person_add_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  "Add Employee",
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: false,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
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

  Widget _buildRoleChip(String value, String label, IconData icon) {
    final isSelected = roleController.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => roleController.value = value,
        child: AnimatedScale(
          scale: isSelected ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
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
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected
                        ? (value == 'ADMIN'
                              ? Icons.shield_rounded
                              : Icons.person_rounded)
                        : icon,
                    key: ValueKey(isSelected),
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
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
      ),
    );
  }

  void _handleSubmit() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      AppSnackbar.show(
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
    if (roleController.value.isEmpty) {
      AppSnackbar.show(
        "Error",
        "Please select a role",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
      return;
    }
    memberController.addMember(
      Member(
        name: nameController.text,
        role: roleController.value,
        email: emailController.text,
        password: passwordController.text,
        tasks: [],
      ),
    );
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
