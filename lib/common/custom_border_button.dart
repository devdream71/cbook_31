import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBorderButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback onLongPress;
  final bool isDeleted;
  final VoidCallback? onDelete;

  const CustomBorderButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0xffdfe8f4),
    this.borderColor = Colors.black45,
    required this.textColor,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.all(4.0),
    required this.onLongPress,
    this.isDeleted = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allows positioning outside the button
      children: [
        InkWell(
          onLongPress: onLongPress,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: backgroundColor,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Padding(
                padding: padding,
                child: Text(
                  label,
                  style: GoogleFonts.lato(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isDeleted && onDelete != null)
          Positioned(
            top: -4, // Move the icon above the button
            right: -4, // Move the icon to the right of the button
            child: GestureDetector(
              onTap: onDelete,
              child: const CircleAvatar(
                radius: 8, // Adjust size if necessary
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
