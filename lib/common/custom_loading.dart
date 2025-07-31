import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color? loaderColor;

  const CustomLoadingWidget({
    required this.loaderColor,
    super.key,
    required this.imagePath,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 4.0,
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor!),
          ),
        ),
        ClipOval(
          child: Image.asset(
            imagePath,
            width: size * 0.6, // Adjust size for the image
            height: size * 0.6,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
