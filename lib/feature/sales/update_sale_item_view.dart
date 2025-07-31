import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_model.dart';
import 'package:cbook_dt/feature/sales/sales_update.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateSaleItemView extends StatefulWidget {
  final index;
  final SaleUpdateProvider provider;
  // final SaleDetail itemDetail;
  final SaleUpdateModel itemDetail;
  final Map<int, String> itemMap;
  final Map<int, String> unitMap;
  final List<dynamic> itemList;
  final dynamic itemDiscoumtAmount;
  final dynamic itemDiscountPercentance;
  final dynamic ItemtaxAmount;
  final dynamic ItemtaxPercentance;

  const UpdateSaleItemView({
    Key? key,
    required this.index,
    required this.itemDetail,
    required this.provider,
    required this.itemMap,
    required this.unitMap,
    required this.itemList,
    this.itemDiscountPercentance,
    this.itemDiscoumtAmount,
    this.ItemtaxAmount,
    this.ItemtaxPercentance,
  }) : super(key: key);

  @override
  _UpdateSaleItemViewState createState() => _UpdateSaleItemViewState();
}

class _UpdateSaleItemViewState extends State<UpdateSaleItemView> {
  
  int? selectedItemId;

  List<String> getFilteredUnitsForSelectedItem() {
    if (selectedItemId == null) return [];

    final item = widget.itemList.firstWhere(
      (element) => element['id'] == selectedItemId,
      orElse: () => null,
    );

    if (item == null) return [];

    final primaryUnitId = item['unit_id'];
    final secondaryUnitId = item['secondary_unit_id'];

    final unitNames = <String>[];

    // Use unitMap to convert unitId → name (e.g., 5 → "Pc")
    if (primaryUnitId != null && widget.unitMap.containsKey(primaryUnitId)) {
      unitNames.add(widget.unitMap[primaryUnitId]!);
    }

    if (secondaryUnitId != null &&
        widget.unitMap.containsKey(secondaryUnitId)) {
      unitNames.add(widget.unitMap[secondaryUnitId]!);
    }

    return unitNames;
  }

  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();

  String? selectedItemName;
  String? selectedUnitName;

  String? selectedTaxName;
  String? selectedTaxId;

  void calculateSubtotal() {
    double price = double.tryParse(widget.provider.priceController.text) ?? 0.0;
    double qty = double.tryParse(widget.provider.qtyController.text) ?? 0.0;
    double subTotal = price * qty;
    widget.provider.subTotalController.text =
        subTotal.toStringAsFixed(2); // Format as needed
  }

  @override
  void initState() {
    super.initState();

    // Get the item and unit name using the maps
    selectedItemName =
        widget.itemMap[int.tryParse(widget.itemDetail.itemId)] ?? 'Select Item';

    // unitId is in the format: "5_Packet_1" => we only need the first part
    final unitIdOnly = int.tryParse(widget.itemDetail.unitId.split("_")[0]);
    selectedUnitName = widget.unitMap[unitIdOnly] ?? 'Select Unit';

    selectedItemId = int.tryParse(widget.itemDetail.itemId);  

    widget.provider.saveData(
      itemId: widget.itemDetail != null
          ? widget.itemDetail.itemId.toString()
          : 'No Items Available',
      unitId: widget.itemDetail != null
          ? widget.itemDetail.unitId.toString() ?? 'pc'
          : 'No Units Available',
      price: widget.itemDetail.price,
      qty: widget.itemDetail.qty,
      subtotal: widget.itemDetail.subTotal,
    );
  }

  void updateItem() {
    debugPrint("Updating item:");
    debugPrint("Selected Item: $selectedItemName");
    debugPrint("Selected Unit: $selectedUnitName");
    debugPrint("Qty: ${qtyController.text}");
    debugPrint("Price: ${priceController.text}");
    debugPrint("Subtotal: ${subTotalController.text}");

    // Pass the updated values back to the provider
    Provider.of<SaleUpdateProvider>(context, listen: false).updateSelectedItem(
        selectedItemName ?? ''); // Update item name in provider

    Provider.of<SaleUpdateProvider>(context, listen: false).updateSelectedUnit(
        selectedUnitName ?? ''); // Update unit name in provider

    // Pass updated values to other relevant fields
    Provider.of<SaleUpdateProvider>(context, listen: false).qtyController.text =
        qtyController.text;

    Provider.of<SaleUpdateProvider>(context, listen: false)
        .priceController
        .text = priceController.text;

    Provider.of<SaleUpdateProvider>(context, listen: false)
        .subTotalController
        .text = subTotalController.text;

    Provider.of<SaleUpdateProvider>(context, listen: false).qtyController.text =
        qtyController.text;

    setState(() {});

    // Navigate back with the updated data
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemPurchaseProvider =
        Provider.of<SaleUpdateProvider>(context, listen: true);

    final controller = Provider.of<SalesController>(context, listen: false);

    widget.provider.priceController.addListener(calculateSubtotal);
    widget.provider.qtyController.addListener(calculateSubtotal);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Sales Update Item",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ////==>Item

                  Opacity(
                    opacity: 0.6,
                    child: IgnorePointer(
                      ignoring: true,
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomDropdownTwo(
                          labelText: 'Item',
                          items: widget.itemMap.isNotEmpty
                              ? widget.itemMap.values.toList()
                              : [
                                  'No Items Available'
                                ], // Show a default message if empty
                          hint: selectedItemName ??
                              'Select Item', // ✅ Show selected item
                          selectedItem: selectedItemName,
                          width: double.infinity,
                          height: 30,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedItemName = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  ///==>Item Stock
                  Consumer<AddItemProvider>(
                    builder: (context, stockProvider, child) {
                      //controller.mrpController.text = stockProvider.stockData!.price.toString();
                      if (stockProvider.stockData != null) {
                        controller.mrpController.text =
                            stockProvider.stockData!.price.toString();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Stock Available:  ${stockProvider.stockData!.unitStocks} ৳ ${stockProvider.stockData!.price} ",
                              //"   Stock Available: ${stockProvider.stockData!.stocks} (${stockProvider.stockData!.unitStocks}) ৳ ${stockProvider.stockData!.price} ",

                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "   ", // Updated message for empty stock
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),

                  //=>Qty , unit
                  Row(
                    children: [
                      //qty
                      Expanded(
                        child: AddSalesFormfield(
                            labelText: 'QTY',
                            //label: "Qty",
                            controller: widget.provider.qtyController),
                      ),
                      const SizedBox(
                        width: 5,
                      ),

                      //unit
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: CustomDropdownTwo(
                                labelText: 'Unit',
                                // items: widget.unitMap.isNotEmpty
                                //     ? widget.unitMap.values.toList()
                                //     : [
                                //         'No Units Available'
                                //       ], // Show a default message if empty
                                items:
                                    getFilteredUnitsForSelectedItem().isNotEmpty
                                        ? getFilteredUnitsForSelectedItem()
                                        : ['No Units Available'],
                                hint: selectedUnitName ??
                                    'Select Unit', // Show selected unit or default hint
                                width: double.infinity,
                                selectedItem: selectedUnitName,
                                height: 30,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedUnitName = newValue;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  //price
                  AddSalesFormfield(
                      labelText: "Price",
                      //label: "Price",
                      controller: widget.provider.priceController),

                  const SizedBox(
                    height: 8,
                  ),

                  //discout amount, discount percentance
                  Row(children: [
                    Expanded(
                      child: Column(
                        children: [
                          //discount percentance
                          AddSalesFormfield(
                            labelText: "Discount (%)",
                            //label: "Discount (%)",
                            controller:
                                widget.provider.itemDiscountPercentance,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              widget.provider.lastChanged = 'percent';
                              widget.provider.calculateSubtotal();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    //discount amount
                    Expanded(
                      child: Column(
                        children: [
                          AddSalesFormfield(
                            labelText: "Discount (Amount)",
                            controller: widget.provider.itemDiscountAmount,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              widget.provider.lastChanged = 'amount';
                              widget.provider.calculateSubtotal();
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(
                    height: 10,
                  ),

                  // ✅ VAT/TAX Dropdown Row
                  Row(
                    children: [
                      // Dropdown
                      Expanded(
                        child: Consumer<TaxProvider>(
                          builder: (context, taxProvider, child) {
                            if (taxProvider.isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (taxProvider.taxList.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No tax options available.',
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///tax

                                    CustomDropdownTwo(
                                      labelText: 'Vat/Tax',
                                      //hint: 'Select VAT/TAX',
                                      items: taxProvider.taxList
                                          .map((tax) =>
                                              "${tax.name} - (${tax.percent})")
                                          .toList(),
                                      width: double.infinity,
                                      height: 30,
                                      selectedItem: widget.provider.itemTaxVatPercentance.text,  //selectedTaxName,
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedTaxName = newValue;

                                          final nameOnly =
                                              newValue?.split(" - ").first;

                                          final selected =
                                              taxProvider.taxList.firstWhere(
                                            (tax) => tax.name == nameOnly,
                                            orElse: () =>
                                                taxProvider.taxList.first,
                                          );

                                          selectedTaxId =
                                              selected.id.toString();

                                          widget.provider.selectedTaxPercent =
                                              double.tryParse(selected.percent);

                                          // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                          widget.provider.taxPercent = widget
                                                  .provider
                                                  .selectedTaxPercent ??
                                              0.0;

                                          widget.provider.updateTaxPaecentId(
                                              '${selectedTaxId}_${widget.provider.selectedTaxPercent}');

                                          print(
                                              'tax_percent: "${controller.taxPercentValue}"');

                                          //controller.calculateSubtotal();

                                          debugPrint(
                                              "Selected Tax ID: $selectedTaxId");
                                          debugPrint(
                                              "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                        });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      ///tax amount
                      Expanded(
                        child: AddSalesFormfield(
                          labelText: "TAX amount",
                          controller: TextEditingController(
                            text: widget.provider.itemTaxVatAmount.text, // 👈 show calculated tax
                          ),
                          keyboardType: TextInputType.number,
                          //readOnly: true, // 👈 prevent manual editing
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  AddSalesFormfield(
                      readOnly: true,
                      labelText: "Subtotal",
                      controller: widget.provider.subTotalController),
                  const SizedBox(height: 20),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  updateItem();
                  widget.provider
                      .updateSaleDetail(widget.index); // global update
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue color for update button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Sale",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
