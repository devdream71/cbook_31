import 'package:flutter/material.dart';

class AddSalesFormfield extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final TextStyle textStyle;
  final InputDecoration decoration;
  final double height;
  //final double width;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;
  final String? labelText;

  const AddSalesFormfield({
    super.key,
    this.label,
    required this.controller,
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.black),
    this.decoration = const InputDecoration(),
    this.height = 30,
    //this.width = 150,
    this.validator, // Accept validator
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        SizedBox(
          height: height,
          width: double.infinity,
          child: TextFormField(
            keyboardType: keyboardType,
            controller: controller,
            validator: validator,
            style: textStyle,
            onChanged: onChanged,
            readOnly: readOnly,

            ///unbderline
            autocorrect: false,
            enableSuggestions: false,
            

            ///underline
            decoration: decoration.copyWith(
              fillColor: Colors.white,
              labelText: labelText,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              floatingLabelStyle: const TextStyle(
                  fontSize: 12, color: Colors.green), // when floating at top
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: const BorderSide(color: Colors.green, width: 1),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 10,
              ),
              //enableBroder: OutlineInputBorder()
            ),
          ),
        ),
      ],
    );
  }
}
