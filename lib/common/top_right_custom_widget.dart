import 'package:flutter/material.dart';

class TopRightCustomWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType inputType;
  final bool isDatePicker;
  final bool isTimePicker;
  final Function? onTap;
  final String? formattedValue;

  const TopRightCustomWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.inputType = TextInputType.text,
    this.isDatePicker = false,
    this.isTimePicker = false,
    this.onTap,
    this.formattedValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 90,
      child: InkWell(
        onTap: onTap as void Function()?,
        child: InputDecorator(
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: _buildSuffixIcon(context),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          child: _buildInputField(),
        ),
      ),
    );
  }
  

  Widget _buildSuffixIcon(BuildContext context) {
    if (isDatePicker) {
      return Icon(
        Icons.calendar_today,
        size: 16,
        color: Theme.of(context).primaryColor,
      );
    } else if (isTimePicker) {
      return Icon(
        Icons.timer,
        size: 16,
        color: Theme.of(context).primaryColor,
      );
    }
    return const SizedBox.shrink(); // Default empty icon
  }

  Widget _buildInputField() {
    if (isDatePicker || isTimePicker) {
      return Text(
        formattedValue ?? "Select $hintText",
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
    }
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black, fontSize: 12),
      keyboardType: inputType,
      cursorHeight: 12, // Match cursor height to text size
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}






