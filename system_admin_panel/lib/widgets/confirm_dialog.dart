import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.confirmColor = Colors.red,
    required this.onConfirm,
  });

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    Color confirmColor = Colors.red,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmText, style: TextStyle(color: confirmColor)),
        ),
      ],
    );
  }
}
