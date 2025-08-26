// In lib/utils/dialog_helper.dart

import 'package:flutter/material.dart';

enum DialogType { success, error, info }

class DialogHelper {
  static void showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    DialogType type = DialogType.info,
  }) {
    IconData icon;
    Color color;

    switch (type) {
      case DialogType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case DialogType.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case DialogType.info:
      default:
        icon = Icons.info;
        color = Colors.blue;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
