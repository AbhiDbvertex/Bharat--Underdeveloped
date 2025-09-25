/*import 'package:flutter/material.dart';

import '../main.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        SnackBarType type = SnackBarType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    // if (!context.mounted) return;


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
}*/
/////////////////
import 'package:flutter/material.dart';
import 'package:get/get.dart';  // Make sure GetX is imported

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
      BuildContext context, { // still required, but not used internally
        required String message,
        SnackBarType type = SnackBarType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    // Map SnackBarType to colors and icons
    final bgColor = _getBackgroundColor(type);
    final iconData = _getIcon(type);
    final title = _getTitle(type);

    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(iconData, color: Colors.white),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 8,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
    );
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange.shade300;
      case SnackBarType.info:
      default:
        return Colors.blue;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
      default:
        return Icons.info;
    }
  }

  static String _getTitle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return "Success";
      case SnackBarType.error:
        return "Error";
      case SnackBarType.warning:
        return "Warning";
      case SnackBarType.info:
      default:
        return "Info";
    }
  }
}
