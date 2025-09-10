import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';

class PriceOptionSelector extends StatelessWidget {
  final String title;
  final String groupValue;
  final Function(String) onChanged;
  final TextEditingController controller;
  final bool showBlankOption; 

  const  PriceOptionSelector({
    super.key,
    required this.title,
    required this.groupValue,
    required this.onChanged,
    required this.controller,
    this.showBlankOption = true, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "$title Price",
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Show Blank Price Option only if `showBlankOption` is true
              if (showBlankOption)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox
                    (
                     // color: Colors.brown,
                      child: Radio<String>(
                        value: "blank",
                        groupValue: groupValue,
                        onChanged: (value) {
                          onChanged(value!);
                        },
                      ),
                    ),
                     const SizedBox(
                      //color: Colors.amber,
                      child:   Text("Blank Price", style: TextStyle(color: Colors.black, fontSize: 12))),
                  ],
                ),
              /// Sales/Purchase Price Option
              SizedBox(
                //color: Colors.red,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<String>(
                      value: "sales",
                      groupValue: groupValue,
                      onChanged: (value) {
                        onChanged(value!);
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$title Price", style: const TextStyle(color: Colors.black, fontSize: 12)),
                        if (groupValue == "sales")
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150), // Fixed width constraint
                            child: AddSalesFormfield(
                              label: " ",
                              controller: controller,
                               
                               keyboardType: TextInputType.number,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // You can add more options like Purchase or MRP similarly, maintaining the same structure
            ],
          ),
      ],
    );
  }
}


