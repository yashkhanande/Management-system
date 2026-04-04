import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static SnackbarController show(
    String title,
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition? snackPosition,
    EdgeInsets? margin,
    double? borderRadius,
  }) {
    // ignore: unused_local_variable
    final ignoredStyleArgs = (
      duration,
      backgroundColor,
      colorText,
      snackPosition,
      margin,
      borderRadius,
    );

    return Get.snackbar(
      title,
      message,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.black,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }
}
