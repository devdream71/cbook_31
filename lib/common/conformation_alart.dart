import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String titleBottomRight;
  final String content;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    Key? key,
    required this.title,
    required this.titleBottomRight,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,  style: const TextStyle(color: Colors.black)),
      content: Text(
        content,
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.black),),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child:  Text(titleBottomRight, style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
