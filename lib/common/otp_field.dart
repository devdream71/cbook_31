import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpField extends StatelessWidget {
  final int index;
  final ColorScheme colorScheme;
  final Function(String, FocusNode) onChanged;
  final TextEditingController controller; // Add this line

  const OtpField({
    super.key,
    required this.index,
    required this.colorScheme,
    required this.onChanged,
    required this.controller, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    return TextField(
      controller: controller, // Use the controller here
      maxLength: 1,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      focusNode: focusNode,
      style: GoogleFonts.notoSansPhagsPa(
          fontSize: 18, color: colorScheme.onSecondary),
      onChanged: (value) => onChanged(value, focusNode),
      decoration: InputDecoration(
        counterText: "",
        border: const UnderlineInputBorder(
            // borderRadius: BorderRadius.circular(10),
            ),
        enabledBorder: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}


