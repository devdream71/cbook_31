import 'package:flutter/material.dart';

/// A circular close button with customizable styles.
class CloseButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final double borderWidth;

  const CloseButtonWidget({
    super.key,
    required this.onPressed,
    this.size = 30.0,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.iconColor = Colors.black,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close,
          size: size * 0.6, // Icon scaled relative to button size
          color: iconColor,
        ),
      ),
    );
  }
}
