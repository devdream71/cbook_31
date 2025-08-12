//  ///purchase item add in list.
//   void showSalesDialog(
//       BuildContext context, PurchaseController controller) async {
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;

//     // final categoryProvider =
//     //     Provider.of<ItemCategoryProvider>(context, listen: false);

//     final unitProvider = Provider.of<UnitProvider>(context, listen: false);

//     final fetchStockQuantity =
//         Provider.of<AddItemProvider>(context, listen: false);

    
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );
 

//     // ✅ Pop the loading dialog
//     Navigator.of(context).pop();

//     // Define local state variables
//     String? selectedCategoryId;
//     String? selectedSubCategoryId;

//     // List<String> unitIdsList = [];

//     String? selectedItemName;
//     ItemsModel? selectedItemData;
//     int? selectedItemId;

//     // ✅ Your existing variables
//     List<String> unitIdsList = [];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return Dialog(
//               backgroundColor: Colors.grey.shade400,
//               child: Container(
//                 height: 300, //550
//                 // width: Constraints.maxWidth,
//                 decoration: BoxDecoration(
//                   color: const Color(0xffe7edf4),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Column(
//                   children: [
//                     ///header, add item & service , and close icon
//                     Container(
//                       height: 30,
//                       color: const Color(0xff278d46),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const SizedBox(
//                               width:
//                                   30), // Placeholder for left spacing (can be removed or adjusted)

//                           // Centered text and icon
//                           const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(width: 5),
//                               Text(
//                                 "Add Item & service",
//                                 style: TextStyle(
//                                     color: Colors.yellow,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),

//                           InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 4.0),
//                               child: CircleAvatar(
//                                   radius: 10,
//                                   backgroundColor: Colors.grey.shade100,
//                                   child: const Icon(
//                                     Icons.close,
//                                     size: 18,
//                                     color: Colors.green,
//                                   )),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 6.0, right: 6.0, top: 4.0),
//                       child: Column(
//                         children: [
//                           const SizedBox(
//                             height: 3,
//                           ),

//                           // Category and Subcategory Row

//                           const SizedBox(
//                             height: 5,
//                           ),

//                           const Column(children: [
//                             /// Category and Subcategory Row
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 /////===> category

//                                 SizedBox(width: 10),
//                               ],
//                             ),

//                             SizedBox(height: 5),
//                           ]),

//                           ///new item working for base and secondary unit.

                          
//                           ///new item selected. for unit show in one click.
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Consumer<AddItemProvider>(
//                               builder: (context, itemProvider, child) {
//                                 return SizedBox(
//                                   height: 30,
//                                   width: double.infinity,
//                                   child: itemProvider.isLoading
//                                       ? const Center(
//                                           child: CircularProgressIndicator())
//                                       : CustomDropdownTwo(
//                                           enableSearch: true,
//                                           hint: 'Select Item',
//                                           items: itemProvider.items
//                                               .map((item) => item.name)
//                                               .toList(),
//                                           width: double.infinity,
//                                           height: 30,
//                                           selectedItem: selectedItemName,
//                                           onChanged: (value) async {
//                                             debugPrint(
//                                                 '=== Item Selected: $value ===');

//                                             // Find the selected item from the provider
//                                             final selectedItem =
//                                                 itemProvider.items.firstWhere(
//                                               (item) => item.name == value,
//                                             );

//                                             // ✅ CRITICAL: Update state FIRST before any async operations
//                                             setState(() {
//                                               selectedItemName = value;
//                                               selectedItemData = selectedItem;
//                                               selectedItemId = selectedItem.id;

//                                               // ✅ Clear units immediately and update controller state
//                                               unitIdsList.clear();

//                                               // Set controller properties immediately
//                                               controller.seletedItemName =
//                                                   selectedItem.name;
//                                               controller.selcetedItemId =
//                                                   selectedItem.id.toString();

//                                               controller.purchasePrice =
//                                                   selectedItem.purchasePrice
//                                                           is int
//                                                       ? (selectedItem
//                                                                   .purchasePrice
//                                                               as int)
//                                                           .toDouble()
//                                                       : (selectedItem
//                                                               .purchasePrice ??
//                                                           0.0);

//                                               controller.unitQty =
//                                                   selectedItem.unitQty ?? 1;

//                                               controller.mrpController.text =
//                                                   controller.purchasePrice
//                                                       .toStringAsFixed(2);
//                                             });

//                                             debugPrint(
//                                                 'Selected Item Details:');
//                                             debugPrint(
//                                                 '- ID: ${selectedItem.id}');
//                                             debugPrint(
//                                                 '- Name: ${selectedItem.name}');
//                                             debugPrint(
//                                                 '- Purchase Price: ${selectedItem.purchasePrice}');

//                                             // Fetch stock quantity
//                                             if (controller.selcetedItemId !=
//                                                 null) {
//                                               fetchStockQuantity
//                                                   .fetchStockQuantity(controller
//                                                       .selcetedItemId!);
//                                             }

//                                             // ✅ Ensure unitProvider is loaded
//                                             if (unitProvider.units.isEmpty) {
//                                               await unitProvider.fetchUnits();
//                                             }

//                                             // ✅ Now populate units and update state again
//                                             setState(() {
//                                               // Clear units again (defensive programming)
//                                               unitIdsList.clear();

//                                               // ===> Primary unit
//                                               if (selectedItem.unitId != null) {
//                                                 final unit = unitProvider.units
//                                                     .firstWhere(
//                                                   (unit) =>
//                                                       unit.id.toString() ==
//                                                       selectedItem.unitId
//                                                           .toString(),
//                                                   orElse: () => Unit(
//                                                     id: 0,
//                                                     name: 'Unknown',
//                                                     symbol: '',
//                                                     status: 0,
//                                                   ),
//                                                 );
//                                                 if (unit.id != 0) {
//                                                   unitIdsList.add(unit.name);
//                                                   controller.primaryUnitName =
//                                                       unit.name;
//                                                   controller.selectedUnit =
//                                                       unit.name;
//                                                   controller
//                                                       .selectedUnitIdWithNameFunction(
//                                                           "${unit.id}_${unit.name}");
//                                                 }
//                                               }

//                                               // ===> Secondary unit
//                                               if (selectedItem
//                                                       .secondaryUnitId !=
//                                                   null) {
//                                                 final secondaryUnit =
//                                                     unitProvider.units
//                                                         .firstWhere(
//                                                   (unit) =>
//                                                       unit.id.toString() ==
//                                                       selectedItem
//                                                           .secondaryUnitId
//                                                           .toString(),
//                                                   orElse: () => Unit(
//                                                     id: 0,
//                                                     name: 'Unknown',
//                                                     symbol: '',
//                                                     status: 0,
//                                                   ),
//                                                 );
//                                                 if (secondaryUnit.id != 0) {
//                                                   unitIdsList
//                                                       .add(secondaryUnit.name);
//                                                   controller.secondaryUnitName =
//                                                       secondaryUnit.name;
//                                                 }
//                                               }
//                                             });

//                                             debugPrint(
//                                                 "Units Available: $unitIdsList");
//                                             debugPrint(
//                                                 "purchase price ===> ${controller.purchasePrice}");
//                                           }),
//                                 );
//                               },
//                             ),
//                           ),

//                           ///stock
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               //qty
//                               Column(
//                                 children: [
//                                   SizedBox(
//                                     width: 150,
//                                     child: AddSalesFormfield(
//                                       labelText: "Qty",
//                                       label: "",
//                                       controller: controller.qtyController,
//                                       keyboardType: TextInputType.number,
//                                       //xyz
//                                     ),
//                                   ),
//                                 ],
//                               ),

                           

//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 20),
//                                   SizedBox(
//                                     width: 150,
//                                     child: CustomDropdownTwo(
//                                       key: ValueKey(
//                                           'unit_dropdown_${selectedItemId}_${unitIdsList.length}'), // ✅ Force rebuild when units change
//                                       labelText: "Unit",
//                                       hint: 'Select Unit',
//                                       items: unitIdsList,
//                                       width: 150,
//                                       height: 30,
//                                       selectedItem: unitIdsList.isNotEmpty &&
//                                               controller.selectedUnit != null &&
//                                               unitIdsList.contains(
//                                                   controller.selectedUnit)
//                                           ? controller.selectedUnit
//                                           : (unitIdsList.isNotEmpty
//                                               ? unitIdsList.first
//                                               : null), // ✅ Better selection logic
//                                       onChanged: (selectedUnit) {
//                                         debugPrint(
//                                             "Selected Unit: $selectedUnit");

//                                         controller.selectedUnit = selectedUnit;

//                                         final selectedUnitObj =
//                                             unitProvider.units.firstWhere(
//                                           (unit) => unit.name == selectedUnit,
//                                           orElse: () => Unit(
//                                               id: 0,
//                                               name: "Unknown",
//                                               symbol: "",
//                                               status: 0),
//                                         );

//                                         controller.selectedUnitIdWithNameFunction(
//                                             "${selectedUnitObj.id}_${selectedUnitObj.symbol}");

//                                         debugPrint(
//                                             "🆔 Unit ID: ${selectedUnitObj.id}_${selectedUnitObj.symbol}");

                                     
//   setState(() {
//     if (selectedUnit == controller.secondaryUnitName) {
//       double newPrice = controller.purchasePrice / controller.unitQty;
//       controller.mrpController.text = newPrice.toStringAsFixed(2);
//     } else if (selectedUnit == controller.primaryUnitName) {
//       controller.mrpController.text = controller.purchasePrice.toStringAsFixed(2);
//     }
    
//     // ✅ CRITICAL: Calculate subtotal after price update
//     // This might be named differently in your controller
//     // Common method names: calculateSubtotal(), updateSubtotal(), dialogtotalController()
//     controller.dialogtotalController(); // or whatever your subtotal calculation method is called
    
  
//   });
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),

//                           ///price
//                           AddSalesFormfield(
//                             labelText: "Price",
//                             label: "",
//                             controller: controller.mrpController,

//                             ///.!purchase price
//                             keyboardType: TextInputType.number,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),

//                     Consumer<PurchaseController>(
//                       builder: (context, controller, _) => Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             const Text("Subtotal: ",
//                                 style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold)),
//                             const SizedBox(width: 5),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 7.0),
//                               child: Text(
//                                 controller.subtotalItemDiolog
//                                     .toStringAsFixed(2),
//                                 style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
                        
//                         const SizedBox(
//                           width: 4,
//                         ),

//                         /// add item
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Align(
//                             alignment: Alignment.bottomRight,
//                             child: InkWell(
//                               onTap: () async {
//                                 debugPrint("🟢 Add Item button tapped");
//                                 debugPrint(
//                                     "🔹 Selected Unit: ${controller.selectedUnit}");
//                                 debugPrint(
//                                     "🔹 Selected Unit: ${controller.selectedUnit}");
//                                 debugPrint(
//                                     "🔹 Full Selected Unit Info: ${controller.selectedUnitIdWithName}");

//                                 debugPrint("Add Item");
//                                 debugPrint("selectedItem ============|>");

//                                 debugPrint(selectedItem);

//                                 debugPrint(
//                                   'Selected Unit: ${controller.selectedUnit ?? "None"}',
//                                 );

//                                 // controller.isCash
//                                 //     ? controller.addCashItem()
//                                 //     : controller.addCreditItem();
//                                 // controller.addAmount();

//                                 if (controller.qtyController.text.isEmpty ||
//                                     controller.mrpController.text.isEmpty) {
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(const SnackBar(
//                                     content: Text(
//                                       'Please enter the qty & price',
//                                     ),
//                                     backgroundColor: Colors.red,
//                                   ));
//                                 } else {
//                                   setState(() {
//                                     controller.isCash
//                                         ? controller.addCashItem()
//                                         : controller.addCreditItem();

//                                     controller.addAmount();

//                                     Navigator.pop(context);
//                                   });
//                                 }

//                                 setState(() {
//                                   Provider.of<PurchaseController>(context,
//                                           listen: false)
//                                       .notifyListeners();
//                                 });

//                                 ////clear item n ame
//                                 setState(() {
//                                   controller.seletedItemName = null;

//                                   // ✅ Clear selected category & subcategory
//                                   selectedCategoryId = null;
//                                   selectedSubCategoryId = null;

//                                   // ✅ (Optional) Clear subcategories
//                                   Provider.of<ItemCategoryProvider>(context,
//                                           listen: false)
//                                       .subCategories = [];
//                                 });

//                                 // ✅ Clear stock info
//                                 Provider.of<AddItemProvider>(context,
//                                         listen: false)
//                                     .clearPurchaseStockData();

//                                 controller.mrpController.clear();
//                                 controller.qtyController.clear();
//                               },
//                               child: SizedBox(
//                                 width: 90,
//                                 child: DecoratedBox(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5),
//                                       color: colorScheme.primary,
//                                     ),
//                                     child: const Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 6.0, vertical: 2),
//                                       child: Center(
//                                         child: Text(
//                                           "Add",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14),
//                                         ),
//                                       ),
//                                     )),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 ),
//               ));
//         });
//       },
//     );
//   }
