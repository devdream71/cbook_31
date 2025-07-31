import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;
  final TextStyle? textStyle;

  const CustomRoundButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor = Colors.blue,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSansPhagsPa(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
