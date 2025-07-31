import 'package:flutter/material.dart';

class CreditDropdown extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? borderColor;
  final double height;
  final double width;

  const CreditDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.borderColor,
    this.height = 25,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.grey.shade400),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.grey.shade400),
          ),
        ),
        style: textStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
      ),
    );
  }
}
