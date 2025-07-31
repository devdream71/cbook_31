
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:flutter/material.dart';
 

class PriceOptionSelectorCustomer extends StatefulWidget {
  final String title;
  final String selectedPrice;
  final Function(String?) onPriceChanged;
  final bool isChecked;
  final Function(bool) onCheckedChanged;

  const PriceOptionSelectorCustomer({
    super.key,
    required this.title,
    required this.selectedPrice,
    required this.onPriceChanged,
    required this.isChecked,
    required this.onCheckedChanged,
  });

  @override
  PriceOptionSelectorCustomerState createState() =>
      PriceOptionSelectorCustomerState();
}

class PriceOptionSelectorCustomerState
    extends State<PriceOptionSelectorCustomer> {
  final List<String> priceOptions = [
    "wholesales_price",
    "depo_price",
    "dealer_price",
    "sub_dealer_price",
    "retailer_price"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Checkbox to enable/disable the dropdown
        Row(
          children: [
            Checkbox(
              value: widget.isChecked,
              onChanged: (value) {
                widget.onCheckedChanged(value ?? false);
              },
            ),
            const Text(
              "Price Level",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),

        /// Dropdown (visible only when checkbox is checked)
        if (widget.isChecked)
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: CustomDropdownTwo(
              items: priceOptions
                  .map((price) => price.replaceAll("_", " ").toLowerCase())
                  .toList(),
              hint: 'Select ${widget.title} Price',
              width: double.infinity,
              height: 40,
              onChanged: (value) {
                widget.onPriceChanged(value);
              },
            ),
          ),
      ],
    );
  }
}

