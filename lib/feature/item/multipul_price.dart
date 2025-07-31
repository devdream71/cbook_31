import 'package:cbook_dt/feature/item/provider/item_save_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierCustomerPricePage extends StatefulWidget {
  const SupplierCustomerPricePage({super.key});

  @override
  SupplierCustomerPricePageState createState() =>
      SupplierCustomerPricePageState();
}

class SupplierCustomerPricePageState extends State<SupplierCustomerPricePage> {
  
  final Map<String, bool> _selected = {
    'Wholesales': false,
    'Dealer': false,
    'Retailer': false,
    'E-commerce Store': false,
    'Depo': false,
    'Sub Dealer': false,
    'Broker': false,
    'Online Store': false,
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

  void getCategoryPrices() {
    final Map<String, String> categoryPriceData = {};

    _controllers.forEach((label, controller) {
      if (_selected[label] == true) {
        categoryPriceData[label] = controller.text;
      }
    });

    Provider.of<ItemProvider>(context, listen: false)
        .setCategoryPriceValues(categoryPriceData);

    debugPrint('Data saved to provider: $categoryPriceData');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: _selected.keys.map((label) {
          return SizedBox(
            //width: MediaQuery.of(context).size.width / 2 - 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (_selected[label]!)
                        SizedBox(
                          width: 100,
                          child: AddSalesFormfield(
                            //label: "Enter price",
                            controller: _controllers[label]!,
    
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              getCategoryPrices();
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
