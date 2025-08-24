import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class ThemeHelper {
  // Custom Snackbar Function
  static void showCustomSnackBar(
      BuildContext context, {
        required String message,
        SnackBarType type = SnackBarType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    // Select color & icon based on type
    Color bgColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        bgColor = Colors.red;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        bgColor = Colors.orange;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      default:
        bgColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
