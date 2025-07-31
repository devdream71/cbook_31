import 'package:flutter/material.dart';


class CustomDropdownDemo extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownDemo({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
          ),
          height: 30,
          width: double.infinity,
          child: DropdownButton<String>(
            isDense: true,
            value: selectedValue,
            icon: const Icon(Icons.arrow_drop_down),
            isExpanded: true,
            onChanged: onChanged,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
