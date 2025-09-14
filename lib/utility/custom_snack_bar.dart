import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        SnackBarType type = SnackBarType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar(); // Prevent stacking

    final Color bgColor;
    final IconData icon;
    final Color iconColor;
    switch (type) {
      case SnackBarType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        iconColor = Colors.white;
        break;
      case SnackBarType.error:
        bgColor = Colors.red;
        icon = Icons.error;
        iconColor = Colors.white;
        break;
      case SnackBarType.warning:
        bgColor = Colors.orange.shade300;
        icon = Icons.warning;
        iconColor=Colors.red;
        break;
      case SnackBarType.info:
      default:
        bgColor = Colors.blue;
        icon = Icons.info;
        iconColor = Colors.white;
        break;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
