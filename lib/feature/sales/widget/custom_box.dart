import 'package:flutter/material.dart';

class CustomBox extends StatelessWidget {
  final Color color;
  final String text;
  final IconData? icon;
  final Color textColor;
  final Color iconColor; // The icon is now optional

  const CustomBox(
      {super.key,
      required this.text,
      this.icon,
      required this.color,
      required this.textColor,
      this.iconColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.blue, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: iconColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
