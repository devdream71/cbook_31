import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;
  final bool isObscure;
  final ColorScheme colorScheme;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? icon;

  const CustomTextField({
    super.key,
    this.hint,
    required this.colorScheme,
    this.isObscure = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.icon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      validator: widget.validator,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: const UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.colorScheme.primary,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.colorScheme.primary,
            width: 2.0,
          ),
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),

        // 👇 Prefix icon with consistent padding
        prefixIcon: widget.icon != null
            ? Container(
                width: 48, // Fixed width for consistency
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Icon(
                  widget.icon,
                  color: widget.colorScheme.primary,
                  size: 20,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48, // Match the container width
          minHeight: 0,
        ),

        // 👇 Fixed suffix icon with same structure as prefix
        suffixIcon: widget.isObscure
            ? Container(
                width: 48, // Same width as prefix for consistency
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  child: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: widget.colorScheme.primary,
                    size: 20,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48, // Same constraints as prefix
          minHeight: 0,
        ),
      ),
    );
  }
}
