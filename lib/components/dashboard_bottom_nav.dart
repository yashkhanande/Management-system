import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/admin_nav_controller.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  static const _items = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Projects',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_alt_rounded,
      label: 'Employees',
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Analytics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminNavController>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76, maxHeight: 76),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          // Multi-layer shadow for realistic depth
          boxShadow: [
            // Ambient shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
            // Key shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            // Primary color ambient glow
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 56,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                // Layered glass surface
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.97),
                    Colors.white.withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Obx(() {
                final selected = controller.currentIndex.value;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    const totalSlots = 5;
                    final slotWidth = constraints.maxWidth / totalSlots;
                    final selectedSlot = selected < 2 ? selected : selected + 1;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ---- Sliding active pill ----
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          left: selectedSlot * slotWidth + 6,
                          top: -2,
                          bottom: -2,
                          width: slotWidth - 12,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.12),
                                  AppColors.primary.withValues(alpha: 0.06),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.10,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ---- Nav items ----
                        Row(
                          children: List.generate(totalSlots, (slot) {
                            if (slot == 2) {
                              return Expanded(
                                child: _AddProjectButton(
                                  onTap: () => Get.to(() => AddTask()),
                                ),
                              );
                            }

                            final itemIndex = slot < 2 ? slot : slot - 1;
                            return Expanded(
                              child: _NavButton(
                                item: _items[itemIndex],
                                isSelected: selected == itemIndex,
                                onTap: () => controller.changePage(itemIndex),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProjectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProjectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> with TickerProviderStateMixin {
  late final AnimationController _selectCtrl;
  late final Animation<double> _selectAnim;
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapAnim;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _selectAnim = CurvedAnimation(
      parent: _selectCtrl,
      curve: Curves.easeOutBack,
    );

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _tapAnim = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut));

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 30),
        TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0, end: -2), weight: 20),
        TweenSequenceItem(tween: Tween(begin: -2, end: 0), weight: 20),
      ],
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOutCubic));

    if (widget.isSelected) _selectCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _NavButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _selectCtrl.forward(from: 0.0);
      _bounceCtrl.forward(from: 0.0);
    } else if (!widget.isSelected && old.isSelected) {
      _selectCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _selectCtrl.dispose();
    _tapCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final inactive = const Color(0xFFB0B8C4);

    return GestureDetector(
      onTapDown: (_) => _tapCtrl.forward(),
      onTapUp: (_) {
        _tapCtrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _tapCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _tapAnim,
        child: AnimatedBuilder(
          animation: Listenable.merge([_selectAnim, _bounceAnim]),
          builder: (context, _) {
            final t = _selectAnim.value;
            final bounce = _bounceAnim.value;
            final color = Color.lerp(inactive, primary, t)!;

            return Transform.translate(
              offset: Offset(0, bounce),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---- Icon with crossfade between outlined/filled ----
                    SizedBox(
                      height: 26,
                      width: 26,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Inactive (outlined)
                          Opacity(
                            opacity: (1.0 - t).clamp(0.0, 1.0),
                            child: Icon(
                              widget.item.icon,
                              size: 23,
                              color: inactive,
                            ),
                          ),
                          // Active (filled) with scale
                          Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.85 + (0.15 * t),
                              child: Icon(
                                widget.item.activeIcon,
                                size: 24,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ---- Label ----
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: lerpDouble(9.5, 10.5, t),
                        fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w500,
                        color: color,
                        letterSpacing: 0.1,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    // ---- Animated bar indicator ----
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      width: widget.isSelected ? 16 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: widget.isSelected
                            ? LinearGradient(
                                colors: [
                                  primary,
                                  primary.withValues(alpha: 0.6),
                                ],
                              )
                            : null,
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lightweight listenable builder.
class AnimatedBuilder extends StatefulWidget {
  final Listenable animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  State<AnimatedBuilder> createState() => _AnimatedBuilderState();
}

class _AnimatedBuilderState extends State<AnimatedBuilder> {
  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant AnimatedBuilder old) {
    super.didUpdateWidget(old);
    if (widget.animation != old.animation) {
      old.animation.removeListener(_rebuild);
      widget.animation.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}
