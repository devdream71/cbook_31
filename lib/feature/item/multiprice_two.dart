import 'package:cbook_dt/feature/item/provider/item_save_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierCustomerPriceTwoPage extends StatefulWidget {
  const SupplierCustomerPriceTwoPage({super.key});

  @override
  SupplierCustomerPriceTwoState createState() =>
      SupplierCustomerPriceTwoState();
}

class SupplierCustomerPriceTwoState
    extends State<SupplierCustomerPriceTwoPage> {
      
  final Map<String, bool> _selected = {
    'Sale Price': false,
    'Purchase Price': false,
    'MRP Price': false,
  };

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selected.keys.forEach((key) {
      _controllers[key] = TextEditingController();
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // Function to get price values from controllers and save them to the provider
  void getPriceValues() {
    final Map<String, String> priceData = {};

    _controllers.forEach((label, controller) {
      if (_selected[label] == true) {
        priceData[label] = controller.text;
      }
    });

    // Save the price data to the provider
    Provider.of<ItemProvider>(context, listen: false).setPriceValues(priceData);

    debugPrint('Data saved to provider: $priceData');
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _selected.keys.map((label) {
              return SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _selected[label],
                      onChanged: (value) {
                        setState(() {
                          _selected[label] = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              label,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (_selected[label]!)
                            SizedBox(
                              width: 100,
                              child: AddSalesFormfield(
                                controller: _controllers[label]!,
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                   getPriceValues();
                                },
                                
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
 