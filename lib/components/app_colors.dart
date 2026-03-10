import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5F6FA);

  // Primary / Brand
  static const Color primary = Color.fromARGB(223, 57, 27, 255);
  static const Color primaryDark = Color(0xFF5F3EEA);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accent = Color(0xFF4F46E5);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFF4D57);
  static const Color info = Color(0xFF3B82F6);

  // Project accents
  static const Color projectBlue = Color(0xFF2F59F7);
  static const Color projectTeal = Color(0xFF0FA885);
  static const Color projectPink = Color(0xFFE91E63);
  static const Color projectPurple = Color(0xFF8B5CF6);

  // Neutrals
  static Color borderColor = Colors.grey.withValues(alpha: 0.4);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF6B7280);

  // Alert
  static const Color alertBackground = Color(0xFFFFF3F3);
  static const Color alertBorder = Color(0xFFFFD4D6);
  static const Color alertTitle = Color(0xFFBE2D34);

  // Avatar palette
  static const List<Color> avatarColors = [
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
  ];
}
