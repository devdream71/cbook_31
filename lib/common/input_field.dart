import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController ?controller;
  final String hintText;
  final IconData? suffixIcon;
  final Color suffixIconColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final double height;

  const InputField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.suffixIconColor = Colors.black,
    this.hintStyle,
    this.textStyle,
    this.height = 30,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        style: textStyle ?? const TextStyle(color: Colors.black, fontSize: 12),
        cursorHeight: 12,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.only(left: 5, top: 5),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    suffixIcon,
                    size: 16,
                    color: suffixIconColor,
                  ),
                )
              : null,
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
