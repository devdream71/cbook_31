import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/purchase/purchase_update.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/purchase_update_model.dart';

class UpdatePurchaseItemView extends StatefulWidget {
  final index;
  final PurchaseUpdateProvider provider;
  final PurchaseUpdateModel itemDetail;
  final Map<int, String> itemMap;
  final Map<int, String> unitMap;
  final List<dynamic> itemList;

  const UpdatePurchaseItemView({
    super.key,
    required this.index,
    required this.itemDetail,
    required this.provider,
    required this.itemMap,
    required this.unitMap,
    required this.itemList,
  });

  @override
  _UpdatePurchaseItemViewState createState() => _UpdatePurchaseItemViewState();
}

class _UpdatePurchaseItemViewState extends State<UpdatePurchaseItemView> {


  

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

  if (secondaryUnitId != null && widget.unitMap.containsKey(secondaryUnitId)) {
    unitNames.add(widget.unitMap[secondaryUnitId]!);
  }

  return unitNames;
} 




  ///variable declear for unit name, unit id, item, item id,
  
  String? selectedItemName;
  String? selectedUnitName;
  int? selectedItemId;
  int? selectedUnitId;

  void calculateSubtotal() {

    double price = double.tryParse(widget.provider.priceController.text) ?? 0.0;
    double qty = double.tryParse(widget.provider.qtyController.text) ?? 0.0;
    double subTotal = price * qty;
    widget.provider.subTotalController.text = subTotal.toStringAsFixed(2); // Format as needed

  }

  @override
  void initState() {
    super.initState();
    widget.provider.qtyController =
        TextEditingController(text: widget.itemDetail.qty.toString());
    widget.provider.priceController =
        TextEditingController(text: widget.itemDetail.price.toString());
    widget.provider.subTotalController =
        TextEditingController(text: widget.itemDetail.subTotal.toString());

    selectedItemName = widget.itemDetail != null
        ? widget.itemMap[int.tryParse(widget.itemDetail.itemId) ?? 0] ??
            'No Items Available'
        : 'No Items Available';

    selectedUnitName = widget.itemDetail != null
        ? widget.unitMap[widget.itemDetail.unitId] ?? 'Pc'
        : 'No Units Available';

    selectedItemId = int.tryParse(widget.itemDetail.itemId);    
  }

  void updateItem() {
    final priceText = widget.provider.priceController.text.trim();
    final qtyText = widget.provider.qtyController.text.trim();
    final subTotalText = widget.provider.subTotalController.text.trim();

    debugPrint("Updating item:");
    debugPrint("Selected Item: $selectedItemName");
    debugPrint("Selected Unit: $selectedUnitName");
    debugPrint("Qty: $qtyText");
    debugPrint("Price: $priceText");
    debugPrint("Subtotal: $subTotalText");

    final parsedPrice = double.tryParse(priceText);
    final parsedQty = double.tryParse(qtyText);
    final parsedSubTotal = double.tryParse(subTotalText);

    if (parsedPrice == null || parsedQty == null || parsedSubTotal == null) {
      debugPrint("Error: One or more fields contain invalid numbers.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid numeric values")),
      );
      return;
    }

    // Reverse lookup for itemId
    final updatedItemId = widget.itemMap.entries
        .firstWhere((entry) => entry.value == selectedItemName,
            orElse: () => const MapEntry(0, ''))
        .key;

    // Reverse lookup for unitId
    final updatedUnitId = widget.unitMap.entries
        .firstWhere((entry) => entry.value == selectedUnitName,
            orElse: () => const MapEntry(0, ''))
        .key;

    if (updatedItemId == 0 || updatedUnitId == 0) {
      debugPrint("Invalid item or unit selection");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid item or unit selection")),
      );
      return;
    }

    // Update provider list
    widget.provider.purchaseUpdateList[widget.index] = PurchaseUpdateModel(
      itemId: updatedItemId.toString(),
      price: priceText,
      qty: qtyText,
      subTotal: subTotalText,
      unitId: "${updatedUnitId}_$selectedUnitName",
    );

    // Also update response model
    final detail = widget
        .provider.purchaseEditResponse.data?.purchaseDetails?[widget.index];
    if (detail != null) {
      detail.itemId = updatedItemId;
      detail.unitId = updatedUnitId;
      detail.price = parsedPrice.toInt();
      detail.qty = parsedQty.toInt();
      detail.subTotal = parsedSubTotal;
    }

    widget.provider.notifyListeners();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final itemPurchaseProvider =
        Provider.of<PurchaseUpdateProvider>(context, listen: true);

    widget.provider.priceController.addListener(calculateSubtotal);
    widget.provider.qtyController.addListener(calculateSubtotal);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: const Text(
            "Purchase Update Item",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///item dropdown.
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
                      
                              // Reverse lookup item ID from name
                              selectedItemId = widget.itemMap.entries
                                  .firstWhere(
                                    (entry) => entry.value == newValue,
                                    orElse: () => const MapEntry(-1, ''),
                                  )
                                  .key;
                      
                              debugPrint("Selected Item Name: $selectedItemName");
                              debugPrint("Selected Item ID: $selectedItemId");
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ///unit dropdown.
                  SizedBox(
                    child: CustomDropdownTwo(
                      labelText: 'Unit',
                      // items: widget.unitMap.isNotEmpty
                      //     ? widget.unitMap.values.toList()
                      //     : [
                      //         'No Units Available'
                      //       ], // Show a default message if empty

                      items: getFilteredUnitsForSelectedItem().isNotEmpty
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

                          // 🔄 Reverse lookup the unit ID from name
                          selectedUnitId = widget.unitMap.entries
                              .firstWhere(
                                (entry) => entry.value == newValue,
                                orElse: () => const MapEntry(-1, ''),
                              )
                              .key;

                          debugPrint("Selected Unit Name: $selectedUnitName");
                          debugPrint("Selected Unit ID: $selectedUnitId");
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  ///price.
                  AddSalesFormfield(
                      labelText: "Price",
                      controller: widget.provider.priceController),
                  const SizedBox(height: 8),

                  ///qty
                  AddSalesFormfield(
                      labelText: "Qty",
                      controller: widget.provider.qtyController),
                  const SizedBox(height: 8),

                  ///subtotal
                  AddSalesFormfield(
                      labelText: "Subtotal",
                      controller: widget.provider.subTotalController),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  updateItem();

                  widget.provider.updatePurchaseDetail(
                    widget.index,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue color for update button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update ",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
