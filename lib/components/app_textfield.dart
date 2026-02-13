import 'package:flutter/material.dart';

class AppTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const AppTextfield({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      autocorrect: false,
    );
  }
}
