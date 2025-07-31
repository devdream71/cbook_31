import 'package:flutter/material.dart';

class CloseButtonIconNew extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final double size;

  const CloseButtonIconNew({
    Key? key,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.iconColor,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap ?? () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor!, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: 15,
            color: iconColor ?? colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
