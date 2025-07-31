import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;
  final bool isObscure;
  final ColorScheme colorScheme;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // ✅ Validator added
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    this.hint,
    required this.colorScheme,
    this.isObscure = false,
    this.controller,
    this.validator, // ✅ Validator parameter
    this.keyboardType
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
      validator: widget.validator, // ✅ Corrected usage of validator
      style: const TextStyle(fontSize: 12, color: Colors.black),
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        suffixIcon: widget.isObscure
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: widget.colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}

