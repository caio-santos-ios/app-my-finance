import 'package:finance/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Toastfy {
  static void show(BuildContext context, String message, String type) {
    MaterialColor colors = Colors.green;

    if (type == "success") {
      colors = Colors.green;
    }

    if (type == "warning") {
      colors = Colors.orange;
    }

    if (type == "error") {
      colors = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight(600), color: AppColors.light100),
        ),
        backgroundColor: colors,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
