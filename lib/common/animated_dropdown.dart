import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

class AnimatedDropdown extends StatelessWidget {
  final String labelText;
  final String hintText;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const AnimatedDropdown({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.items,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        CustomDropdown<String>(
          closedHeaderPadding: const EdgeInsets.only(left: 5),
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(color: Colors.grey.shade400),
            closedFillColor: const Color(0xffe7edf4),
            closedBorderRadius: BorderRadius.circular(0),
            expandedFillColor: const Color(0xffe7edf4),
            expandedBorderRadius: BorderRadius.circular(0),
            headerStyle: const TextStyle(color: Colors.black, fontSize: 12),
            listItemStyle: const TextStyle(color: Colors.black, fontSize: 12),
            hintStyle: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          hintText: hintText,
          items: items,
          initialItem: initialValue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
