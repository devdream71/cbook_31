import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/sales_return/controller/sales_return_controller.dart';
import 'package:cbook_dt/feature/sales_return/model/sales_return_history_model.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
import 'package:cbook_dt/feature/unit/provider/unit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaleReturnDetailsPage extends StatefulWidget {
  final List<SalesReturnHistoryModel> salesHistory;
  final String itemName;

  const SaleReturnDetailsPage({
    super.key,
    required this.salesHistory,
    required this.itemName,
  });

  @override
  SaleReturnDetailsPageState createState() => SaleReturnDetailsPageState();
}

class SaleReturnDetailsPageState extends State<SaleReturnDetailsPage> {
  final Map<int, TextEditingController> _reductionControllers = {};
  final Map<int, TextEditingController> _unitPriceControllers = {};

  double totalReductionQty = 0;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();

    // Fetch units when the page initializes
    Future.delayed(Duration.zero, () {
      Provider.of<UnitDTProvider>(context, listen: false).fetchUnits();
    });

    Provider.of<SalesReturnController>(context, listen: false)
        .addReductionQtyController(data: widget.salesHistory);

    var controller = Provider.of<SalesReturnController>(context, listen: false);
    // controller.clearReductionQty();
    // controller.clearAll();

    // Initialize controllers for each sales history item
    for (var history in widget.salesHistory) {
      _reductionControllers.putIfAbsent(
        history.salesDetailsID,
        () => TextEditingController(),
      );

      _unitPriceControllers[history.salesDetailsID] = TextEditingController(
        text: history.unitPrice.toString(),
      );
    }
  }

  // Function to calculate total reduction quantity
  void calculateTotalReductionQty() {
    double total = 0;
    _reductionControllers.forEach((key, controller) {
      double value = double.tryParse(controller.text.trim()) ?? 0;
      total += value;
    });

    setState(() {
      totalReductionQty = total;
    });

    calculateTotalPrice(); // Triggers price update
  }

  void calculateTotalPrice() {
    var controller = Provider.of<SalesReturnController>(context, listen: false);
    double total = 0;

    for (int i = 0; i < widget.salesHistory.length; i++) {
      final history = widget.salesHistory[i];
      final reductionText = controller.reductionQtyList[i].text.trim();
      double reductionQty = double.tryParse(reductionText) ?? 0;

      double billQty =
          double.tryParse(history.billQty.split('=').first.trim()) ?? 0;
      if (reductionQty > billQty) {
        reductionQty = billQty;
      }

      // Use stored unit price controller
      final unitPriceController = _unitPriceControllers[history.salesDetailsID];
      double unitPrice = 0;
      if (unitPriceController != null) {
        unitPrice = double.tryParse(unitPriceController.text.trim()) ??
            double.tryParse(history.unitPrice) ??
            0;
      } else {
        unitPrice = double.tryParse(history.unitPrice) ?? 0;
      }

      total += reductionQty * unitPrice;
    }

    setState(() {
      totalPrice = total;
    });
  }

  String _getDefaultUnitName(
      SalesReturnHistoryModel history, UnitDTProvider unitProvider) {
    final baseUnit = unitProvider.units.firstWhere(
      (unit) => unit.id == history.salesUnitId,
      orElse: () =>
          UnitResponseModel(id: 0, name: "Unknown", symbol: "", status: 0),
    );
    return baseUnit.name;
  }

  @override
  void dispose() {
    for (var controller in _reductionControllers.values) {
      controller.dispose();
    }
    for (var controller in _unitPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<SalesReturnController>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<UnitDTProvider>(
      builder: (context, unitProvider, child) {
        if (unitProvider.units.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Sales Return Details")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Get primary and secondary unit info (similar to purchase return)
        String primaryUnitName = '';
        String secondaryUnitName = '';

        if (widget.salesHistory.isNotEmpty) {
          final firstHistory = widget.salesHistory.first;

          final primaryUnit = unitProvider.units.firstWhere(
            (unit) => unit.id == firstHistory.salesUnitId,
            orElse: () => UnitResponseModel(
                id: 0, name: 'Unknown', symbol: '', status: 0),
          );
          primaryUnitName = primaryUnit.symbol;

          // For sales return, we might not have secondary unit in the model
          // But we can still show the conversion if available in unitQty
        }

        return Scaffold(
          backgroundColor: AppColors.sfWhite,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            leading: const BackButton(color: Colors.white),
            title: const Text(
              "Sales Return Details",
              style: TextStyle(color: Colors.yellow, fontSize: 16),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name with unit info
                Text(
                  '${widget.itemName} (1 $primaryUnitName)',
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                ),

                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.salesHistory.length,
                    itemBuilder: (context, index) {
                      final history = widget.salesHistory[index];
                      final unitPriceController =
                          _unitPriceControllers[history.salesDetailsID]!;

                      // Prepare allowed units for dropdown
                      List<String> allowedUnits = [];
                      final primaryUnit = unitProvider.units.firstWhere(
                        (unit) => unit.id == history.salesUnitId,
                        orElse: () => UnitResponseModel(
                            id: 0, name: 'Unknown', symbol: '', status: 0),
                      );
                      if (primaryUnit.id != 0) {
                        allowedUnits.add(primaryUnit.name);
                      }

                      // Add other available units if needed
                      // Note: Sales return model might not have secondary unit info
                      // You can modify this based on your model structure

                      return Column(
                        children: [
                          Card(
                            color: const Color(0xfff4f6ff),
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Bill: ${history.billNumber}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      Text(
                                        "Date: ${history.purchaseDate}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Rate: ${history.rate.split('=').last.split('(').first}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Bill Qty: ${history.billQty.split('=').first.trim()}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Unit Price: ${history.unitPrice}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Unit Qty: ${history.unitQty}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Bill Qty: ${history.billQty.split('=').first.trim()}",
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),

                                      // Unit dropdown
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: CustomDropdownTwo(
                                          labelText: 'Unit',
                                          hint: 'Choose a unit',
                                          items: allowedUnits,
                                          width: 150,
                                          height: 30,
                                          selectedItem: controller
                                                  .getSelectedUnit(index) ??
                                              _getDefaultUnitName(
                                                  history, unitProvider),
                                          onChanged: (selectedUnit) {
                                            debugPrint(
                                                "Selected Unit: $selectedUnit");

                                            controller.setSelectedUnit(
                                                index, selectedUnit!);

                                            final selectedUnitObj =
                                                unitProvider.units.firstWhere(
                                              (unit) =>
                                                  unit.name == selectedUnit,
                                              orElse: () => UnitResponseModel(
                                                id: 0,
                                                name: "Unknown Unit",
                                                symbol: "",
                                                status: 0,
                                              ),
                                            );

                                            debugPrint(
                                                "Selected Unit ID: ${selectedUnitObj.id}_$selectedUnit");

                                            if (selectedUnitObj.id != 0) {
                                              String selectedUnitId =
                                                  selectedUnitObj.id.toString();

                                              // Calculate price based on unit selection
                                              double totalPrice =
                                                  double.tryParse(history.rate
                                                              .toString()
                                                              .split("=")[1]
                                                              .split("(")[0]
                                                              .trim() ??
                                                          "0") ??
                                                      0;

                                              double rawQty = double.tryParse(
                                                      history.unitQty
                                                              ?.toString() ??
                                                          "1") ??
                                                  1;

                                              // Use primary unit
                                              if (selectedUnitId ==
                                                  history.salesUnitId
                                                      .toString()) {
                                                unitPriceController.text =
                                                    (double.tryParse(history
                                                                    .unitPrice
                                                                    ?.toString() ??
                                                                "0") ??
                                                            0)
                                                        .toStringAsFixed(2);

                                                controller
                                                    .selectedUnitIdWithNameFunction(
                                                  "${selectedUnitId}_${selectedUnit}_1",
                                                );
                                              }
                                            }

                                            calculateTotalPrice();
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // Reduction quantity input
                                      SizedBox(
                                        width: 150,
                                        height: 38,
                                        child: AddSalesFormfield(
                                          labelText: 'Reduction Qty',
                                          controller: controller
                                              .reductionQtyList[index],
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            double inputQty =
                                                double.tryParse(value) ?? 0;
                                            double billQty = double.tryParse(
                                                    history.billQty
                                                        .split('=')
                                                        .first
                                                        .trim()) ??
                                                0;

                                            if (inputQty > billQty) {
                                              // Prevent larger value
                                              controller.reductionQtyList[index]
                                                      .text =
                                                  billQty.toStringAsFixed(2);
                                              controller.reductionQtyList[index]
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: controller
                                                        .reductionQtyList[index]
                                                        .text
                                                        .length),
                                              );

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Reduction Qty cannot be greater than Bill Qty."),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            // Save sale return data
                                            controller.saveSaleReturn(
                                              itemId: history.itemID.toString(),
                                              qty: value,
                                              index: index,
                                              price:
                                                  history.unitPrice.toString(),
                                              purchaseDetailsId: history
                                                  .salesDetailsID
                                                  .toString(),
                                              itemName:
                                                  Provider.of<AddItemProvider>(
                                                          context,
                                                          listen: false)
                                                      .getItemName(
                                                          history.itemID),
                                              unitId: history.salesUnitId
                                                  .toString(),
                                              unitName: unitProvider.units
                                                  .firstWhere(
                                                      (u) =>
                                                          u.id ==
                                                          history.salesUnitId,
                                                      orElse: () =>
                                                          UnitResponseModel(
                                                              id: 0,
                                                              name: 'Unknown',
                                                              symbol: '',
                                                              status: 0))
                                                  .name,
                                              unitQty:
                                                  history.unitQty.toString(),
                                            );

                                            setState(() {
                                              calculateTotalReductionQty();
                                              calculateTotalPrice();
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 6),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Fixed Total Qty and Price row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("All QTY: ${controller.getAllQty()}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Text("PC: ${controller.getAllQty()}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Text(
                        "Total Price: ${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        debugPrint(
                            'selected unit =====> ${controller.selectedUnit}');
                        debugPrint(
                            "sales item return ${controller.itemsCashReuturn.length}");

                        final bool isSuccess = controller.isCash
                            ? await controller.saveSaleReturnData()
                            : await controller.saveSaleReturnCreaditData();

                        debugPrint(
                            "sales item return ${controller.itemsCashReuturn.length}");

                        if (isSuccess) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      )),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}







// import 'package:cbook_dt/app_const/app_colors.dart';
// import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
// import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
// import 'package:cbook_dt/feature/sales_return/controller/sales_return_controller.dart';
// import 'package:cbook_dt/feature/sales_return/model/sales_return_history_model.dart';
// import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
// import 'package:cbook_dt/feature/unit/provider/unit_provider.dart'; // ✅ Make sure this is UnitDTProvider
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SaleReturnDetailsPage extends StatefulWidget {
//   final List<SalesReturnHistoryModel> salesHistory;

//   const SaleReturnDetailsPage({super.key, required this.salesHistory});

//   @override
//   SaleReturnDetailsPageState createState() => SaleReturnDetailsPageState();
// }

// class SaleReturnDetailsPageState extends State<SaleReturnDetailsPage> {
//   final Map<int, TextEditingController> _reductionControllers = {};
//   double totalReductionQty = 0;
//   double totalPrice = 0;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Correct Provider used
//     Future.delayed(Duration.zero, () {
//       Provider.of<UnitDTProvider>(context, listen: false).fetchUnits();
//     });

//     Provider.of<SalesReturnController>(context, listen: false)
//         .addReductionQtyController(data: widget.salesHistory);

//     for (var history in widget.salesHistory) {
//       _reductionControllers.putIfAbsent(
//         history.salesDetailsID,
//         () => TextEditingController(),
//       );
//     }
//   }

//   // Function to calculate total reduction quantity
//   void calculateTotalReductionQty() {
//     double total = 0;
//     _reductionControllers.forEach((key, controller) {
//       double value = double.tryParse(controller.text.trim()) ?? 0;
//       total += value;
//     });

//     setState(() {
//       totalReductionQty = total;
//     });

//     //calculateTotalPrice(); // 🔁 Triggers price update
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller =
//         Provider.of<SalesReturnController>(context, listen: false);
//     final colorScheme = Theme.of(context).colorScheme;

//     return Consumer<UnitDTProvider>(
//       builder: (context, unitProvider, child) {
//         if (unitProvider.units.isEmpty) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         return Scaffold(
//           backgroundColor: AppColors.sfWhite,
//           appBar: AppBar(
//             backgroundColor: colorScheme.primary,
//             leading: const BackButton(color: Colors.white),
//             title: const Text(
//               "Sales Return Details",
//               style: TextStyle(color: Colors.yellow, fontSize: 16),
//             ),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: widget.salesHistory.length,
//                     itemBuilder: (context, index) {
//                       final history = widget.salesHistory[index];
//                       final unit = unitProvider.units.firstWhere(
//                         (u) => u.id == history.salesUnitId,
//                         orElse: () => UnitResponseModel(
//                           id: 0,
//                           name: 'Unknown',
//                           symbol: '',
//                           status: 0,
//                         ),
//                       );

//                       return Card(
//                         //color: Colors.white70,
//                         color: const Color(0xfff4f6ff),
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(3.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(history.purchaseDate,
//                                       style: const TextStyle(
//                                           fontSize: 13, color: Colors.black)),
//                                   Text("Bill: ${history.billNumber}",
//                                       style: const TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black)),

//                                   Text(
//                                     "Bill Qty: ${history.billQty.split('=').first.trim()}",
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black),
//                                   ),

//                                   Text("Unit Price: ${history.unitPrice}",
//                                       style: const TextStyle(
//                                           fontSize: 13, color: Colors.black)),

//                                   Text("Unit : ${unit.name}",
//                                       style: const TextStyle(
//                                           fontSize: 13, color: Colors.black)),

//                                   // Text("Rate: ${history.rate}",
//                                   //     style: const TextStyle(
//                                   //         fontSize: 13, color: Colors.black)),

//                                   Text(
//                                     "Rate: ${history.rate.split('=').last.split('(').first}",
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black),
//                                   ),

//                                   // Text("Unit Qty: ${history.unitQty}",
//                                   //     style: const TextStyle(
//                                   //         fontSize: 13,
//                                   //         color: Colors.black,
//                                   //         fontWeight: FontWeight.bold)),

//                                   // const Text("Reduction Qty",
//                                   //     style: TextStyle(
//                                   //         fontSize: 12, color: Colors.black)),
//                                   const SizedBox(height: 3),
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   // Unit Price
//                                   // SizedBox(
//                                   //   width: 100,
//                                   //   child: AddSalesFormfield(
//                                   //     height: 30,
//                                   //     labelText: "Price",
//                                   //     controller: TextEditingController(
//                                   //       text: history.unitPrice,
//                                   //     ),
//                                   //     readOnly: true,
//                                   //   ),
//                                   // ),
//                                   const SizedBox(height: 6),

//                                   // ✅ Unit Name
//                                   // SizedBox(
//                                   //   width: 100,
//                                   //   child: AddSalesFormfield(
//                                   //     height: 30,
//                                   //     labelText: "Unit",
//                                   //     controller: TextEditingController(
//                                   //       text: unit.name,
//                                   //     ),
//                                   //     readOnly: true,
//                                   //     onChanged: (value) {},
//                                   //   ),
//                                   // ),
//                                   const SizedBox(height: 6),


                                  

//                                   // Reduction Qty
//                                   SizedBox(
//                                     width: 100,
//                                     height: 30,
//                                     child: AddSalesFormfield(
//                                       labelText: "Reduction Qty",
//                                       controller:
//                                           controller.reductionQtyList[index],
//                                       keyboardType: TextInputType.number,
//                                       onChanged: (value) {
//                                         // calculateTotalReductionQty();
//                                         // ();

//                                         // controller.saveSaleReturn(
//                                         //   itemId: history.itemID.toString(),
//                                         //   qty: value,
//                                         //   index: index,
//                                         //   price: history.unitPrice.toString(),
//                                         //   purchaseDetailsId:
//                                         //       history.salesDetailsID.toString(),
//                                         //   itemName:
//                                         //       Provider.of<AddItemProvider>(
//                                         //               context,
//                                         //               listen: false)
//                                         //           .getItemName(history.itemID),
//                                         //   // unitName: unit.name,
//                                         //   unitId: unit.id
//                                         //       .toString(), // 👈 from `UnitResponseModel`
//                                         //   unitName: unit.name,
//                                         //   unitQty: history.unitQty.toString(),
//                                         // );

//                                         // onChanged:
//                                         // (value) {
//                                         double inputQty =
//                                             double.tryParse(value) ?? 0;
//                                         double billQty = double.tryParse(history
//                                                 .billQty
//                                                 .split('=')
//                                                 .first
//                                                 .trim()) ??
//                                             0;

//                                         if (inputQty > billQty) {
//                                           // Prevent larger value
//                                           controller.reductionQtyList[index]
//                                                   .text =
//                                               billQty.toStringAsFixed(2);
//                                           controller.reductionQtyList[index]
//                                                   .selection =
//                                               TextSelection.fromPosition(
//                                             TextPosition(
//                                                 offset: controller
//                                                     .reductionQtyList[index]
//                                                     .text
//                                                     .length),
//                                           );

//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             const SnackBar(
//                                               content: Text(
//                                                   "Reduction Qty cannot be greater than Bill Qty."),
//                                               backgroundColor: Colors.red,
//                                             ),
//                                           );
//                                           return;
//                                         }

//                                         calculateTotalReductionQty();

//                                         controller.saveSaleReturn(
//                                           itemId: history.itemID.toString(),
//                                           qty: value,
//                                           index: index,
//                                           price: history.unitPrice.toString(),
//                                           purchaseDetailsId:
//                                               history.salesDetailsID.toString(),
//                                           itemName:
//                                               Provider.of<AddItemProvider>(
//                                                       context,
//                                                       listen: false)
//                                                   .getItemName(history.itemID),
//                                           unitId: unit.id.toString(),
//                                           unitName: unit.name,
//                                           unitQty: history.unitQty.toString(),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("All QTY: ${controller.getAllQty()}",
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black)),
//                       Text("PC: ${controller.getAllQty()}",
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black)),
//                       Text(
//                         "Total Price: ৳${controller.getTotalPrice(widget.salesHistory)}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       final bool isSuccess = controller.isCash
//                           ? await controller.saveSaleReturnData()
//                           : await controller.saveSaleReturnCreaditData();

//                       if (isSuccess) {
//                         Navigator.pop(context);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: const Text("Save",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//                 const SizedBox(height: 60),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
