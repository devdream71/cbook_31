import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/purchase_return/controller/purchase_return_controller.dart';
import 'package:cbook_dt/feature/purchase_return/model/purchase_return_item_details.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PurchaseReturnDetailsPage extends StatefulWidget {
  final List<PurchaseHistoryModel> purchaseHistory;
  final String itemName;

  const PurchaseReturnDetailsPage(
      {super.key, required this.purchaseHistory, required this.itemName});

  @override
  PurchaseReturnDetailsPageState createState() =>
      PurchaseReturnDetailsPageState();
}

class PurchaseReturnDetailsPageState extends State<PurchaseReturnDetailsPage> {
  final Map<int, TextEditingController> _reductionControllers = {};
  final Map<int, TextEditingController> _unitPriceControllers = {};

  TextEditingController priceController = TextEditingController();

  double totalReductionQty = 0;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // Fetch units when the page initializes
    Future.delayed(Duration.zero, () {
      Provider.of<UnitProvider>(context, listen: false).fetchUnits();
    });

    Provider.of<PurchaseReturnController>(context, listen: false)
        .addReductionQtyController(data: widget.purchaseHistory);

    for (var history in widget.purchaseHistory) {
      _reductionControllers.putIfAbsent(
          history.purchaseDetailsId, () => TextEditingController());
    }
    var controller =
        Provider.of<PurchaseReturnController>(context, listen: false);

    controller.clearReductionQty();
    controller.clearAll();

    for (var history in widget.purchaseHistory) {
      _unitPriceControllers[history.purchaseDetailsId] = TextEditingController(
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

    calculateTotalPrice(); // 🔁 Triggers price update
  }

 
  void calculateTotalPrice() {
    var controller =
        Provider.of<PurchaseReturnController>(context, listen: false);
    double total = 0;

    for (int i = 0; i < widget.purchaseHistory.length; i++) {
      final history = widget.purchaseHistory[i];
      final reductionText = controller.reductionQtyList[i].text.trim();
      double reductionQty = double.tryParse(reductionText) ?? 0;

      if (reductionQty > history.currentQty) {
        reductionQty = history.currentQty;
      }

      // Use your stored unit price controller here
      final unitPriceController =
          _unitPriceControllers[history.purchaseDetailsId];
      double unitPrice = 0;
      if (unitPriceController != null) {
        unitPrice = double.tryParse(unitPriceController.text.trim()) ??
            history.unitPrice;
      } else {
        unitPrice = history.unitPrice;
      }

      total += reductionQty * unitPrice;
    }

    setState(() {
      totalPrice = total;
    });
  }

  @override
  void dispose() {
    for (var controller in _reductionControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller =
        Provider.of<PurchaseReturnController>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Purchase Return Details",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Consumer<UnitProvider>(builder: (context, unitProvider, child) {
        if (unitProvider.units.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Purchase Return Detailsfffff")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        String primaryUnitName = '';
        String secondaryUnitName = '';

        if (widget.purchaseHistory.isNotEmpty) {}

        if (widget.purchaseHistory.isNotEmpty) {
          final firstHistory = widget.purchaseHistory.first;

          final primaryUnit = unitProvider.units.firstWhere(
            (unit) => unit.id == firstHistory.unitID,
            orElse: () => Unit(id: 0, name: 'Unknown', symbol: '', status: 0),
          );
          primaryUnitName = primaryUnit.symbol;

          if (firstHistory.secondaryUnitID != null) {
            final secondaryUnit = unitProvider.units.firstWhere(
              (unit) => unit.id == firstHistory.secondaryUnitID,
              orElse: () => Unit(id: 0, name: '', symbol: '', status: 0),
            );
            if (secondaryUnit.id != 0 &&
                secondaryUnit.name != primaryUnit.name) {
              secondaryUnitName = secondaryUnit.symbol;
            }
          }
        }

        final firstHistory = widget.purchaseHistory.first;

        String conversionText = '';

        if (secondaryUnitName.isNotEmpty &&
            firstHistory.billQty.contains('=')) {
          final parts = firstHistory.billQty.split('=');
          if (parts.length == 2) {
            final left = double.tryParse(parts[0].trim());
            final right = double.tryParse(parts[1].trim());
            if (left != null && right != null && left != 0) {
              final result = right / left;
              conversionText =
                  ' = ${result.toStringAsFixed(0)} $secondaryUnitName';
            }
          }
        }

        String _getDefaultUnitName(
            PurchaseHistoryModel history, UnitProvider unitProvider) {
          final baseUnit = unitProvider.units.firstWhere(
            (unit) => unit.id == history.unitID,
            orElse: () => Unit(id: 0, name: "Unknown", symbol: "", status: 0),
          );
          return baseUnit.name;
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable history list

              Text(
                '${widget.itemName} (1 $primaryUnitName$conversionText)',
                style: const TextStyle(color: Colors.black, fontSize: 13),
              ),

              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.purchaseHistory.length,
                  itemBuilder: (context, index) {
                    final history = widget.purchaseHistory[index];

                    /// AK ///new one
                    final unitPriceController =
                        _unitPriceControllers[history.purchaseDetailsId]!;

                    

                    /// ✅ Prepare allowed units (primary + optional secondary)
                    List<String> allowedUnits = [];

                    final primaryUnit = unitProvider.units.firstWhere(
                      (unit) => unit.id == history.unitID,
                      orElse: () =>
                          Unit(id: 0, name: 'Unknown', symbol: '', status: 0),
                    );
                    if (primaryUnit.id != 0) {
                      allowedUnits.add(primaryUnit.name);
                    }

                    // Optional: if your model has secondaryUnitID
                    if (history.secondaryUnitID != null) {
                      final secondaryUnit = unitProvider.units.firstWhere(
                        (unit) => unit.id == history.secondaryUnitID,
                        orElse: () =>
                            Unit(id: 0, name: 'Unknown', symbol: '', status: 0),
                      );
                      if (secondaryUnit.id != 0 &&
                          secondaryUnit.name != primaryUnit.name) {
                        allowedUnits.add(secondaryUnit.name);
                      }
                    }

                    return Column(
                      children: [
                        Card(
                          color: const Color(0xfff4f6ff), //Colors.white70,

                          margin: const EdgeInsets.symmetric(vertical: 3),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Bill: ${history.billNumber},", //Type: ${history.type}
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    Text(
                                      "Account Name: ${history.supplierName == null || history.supplierName.toString().trim().isEmpty ? 'Cash' : history.supplierName}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Date: ${history.purchaseDate}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "Rate: ${history.rate}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "Bill Qty: ${history.billQty}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "Out Qty: ${history.outQty}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "Current Qty: ${history.currentQty}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Unit Price: ${history.unitQty}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 6,
                                    ),

                                    ///unit price.
                                    SizedBox(
                                      width: 150,
                                      height: 30,
                                      child: AddSalesFormfield(
                                        labelText: 'Unit Price',
                                        controller: unitPriceController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          debugPrint("top most $value");
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    ///primary and secondary unit
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0),
                                      child: CustomDropdownTwo(
                                        labelText: 'Unit',
                                        hint: 'Choose a unit',
                                        items: allowedUnits,
                                        width: 150,
                                        height: 30,
                                        selectedItem:
                                            controller.getSelectedUnit(index) ??
                                                _getDefaultUnitName(
                                                    history, unitProvider),
                                        onChanged: (selectedUnit) {
                                          debugPrint(
                                              "Selected Unit: $selectedUnit");

                                          controller.setSelectedUnit(
                                              index, selectedUnit!);

                                          final selectedUnitObj =
                                              unitProvider.units.firstWhere(
                                            (unit) => unit.name == selectedUnit,
                                            orElse: () => Unit(
                                              id: 0,
                                              name: "Unknown Unit",
                                              symbol: "",
                                              status: 0,
                                            ),
                                          );

                                          debugPrint(
                                              "🆔 Selected Unit ID: ${selectedUnitObj.id}_$selectedUnit");

                                          if (selectedUnitObj.id != 0) {
                                            String selectedUnitId =
                                                selectedUnitObj.id.toString();

                                            /// "rate": "160.00=1600.00(16)",

                                            double totalPrice = double.tryParse(
                                                    history.rate
                                                            ?.toString()
                                                            .split("=")[1]
                                                            .split("(")[0]
                                                            .trim() ??
                                                        "0") ??
                                                0;
                                            double rawQty = double.tryParse(
                                                    history.purchaseRawQty
                                                            ?.toString() ??
                                                        "1") ??
                                                1;

                                            // Use secondary unit (e.g., Pieces)
                                            if (selectedUnitId ==
                                                history.secondaryUnitID
                                                    ?.toString()) {
                                              double perUnitPrice =
                                                  totalPrice / rawQty;
                                              unitPriceController.text =
                                                  perUnitPrice
                                                      .toStringAsFixed(2);

                                              controller
                                                  .selectedUnitIdWithNameFunction(
                                                "${selectedUnitId}_${selectedUnit}_${history.unitQty}",
                                              );
                                            }

                                            // 👇 Use primary unit (e.g., Pack)
                                            else if (selectedUnitId ==
                                                history.unitID.toString()) {
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

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    /// reduction qty.
                                    SizedBox(
                                      width: 150,
                                      height: 30,
                                      child: AddSalesFormfield(
                                        labelText: 'Reduction Qty',
                                        controller:
                                            controller.reductionQtyList[index],
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          final reductionText = controller
                                              .reductionQtyList[index].text;
                                          final enteredQty =
                                              double.tryParse(reductionText) ??
                                                  0;

                                          if (enteredQty > history.currentQty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Reduction QTY can't be above current QTY"),
                                              backgroundColor: Colors.red,
                                            ));
                                          }

                                          // Auto-switch to packet if applicable
                                          final selectedUnit =
                                              controller.selectedUnit;
                                          final primaryUnitId = history.unitID;
                                          final secondaryUnitId =
                                              history.secondaryUnitID;
                                          final primaryUnitName = unitProvider
                                              .units
                                              .firstWhere(
                                                  (u) => u.id == primaryUnitId,
                                                  orElse: () => Unit(
                                                      id: 0,
                                                      name: 'Unknown',
                                                      symbol: '',
                                                      status: 0))
                                              .name;

                                          final secondaryUnitName =
                                              secondaryUnitId != null
                                                  ? unitProvider.units
                                                      .firstWhere(
                                                          (u) =>
                                                              u.id ==
                                                              secondaryUnitId,
                                                          orElse: () => Unit(
                                                              id: 0,
                                                              name: 'Unknown',
                                                              symbol: '',
                                                              status: 0))
                                                      .name
                                                  : null;

                                          if (secondaryUnitName != null &&
                                              selectedUnit == primaryUnitName &&
                                              enteredQty >= history.unitQty) {
                                            setState(() {
                                              controller.selectedUnit =
                                                  secondaryUnitName;
                                            });

                                            controller
                                                .selectedUnitIdWithNameFunction(
                                                    "${secondaryUnitId}_${secondaryUnitName}_${history.unitQty}");
                                          }

                                          // Save to controller (optional for API)

                                          controller.savePrucahseReturn(
                                            itemId: history.itemId.toString(),
                                            qty: controller
                                                .reductionQtyList[index].text,
                                            index: index,
                                            price: history.unitPrice.toString(),
                                            purchaseDetailsId: history
                                                .purchaseDetailsId
                                                .toString(),
                                            itemName: widget
                                                .itemName, // fallback from parent
                                            history: history,
                                            unitProvider: unitProvider,
                                          );

                                          /// 👇 This ensures everything is updated correctly
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
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    Text("PC: ${controller.getAllQty()}",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    
                    Text(
                      "Total Price: ${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      debugPrint(
                          'selected unit =====>  ${controller.selectedUnit}');

                      debugPrint(
                          "purchase item return  ${controller.itemsCashReuturn.length}");

                      final bool isSucces = controller.isCash
                          ? await controller.savePurchaseReturnData()
                          : await controller.savePurchaseReturnCreaditData();

                      debugPrint(
                          "purchase item return  ${controller.itemsCashReuturn.length}");

                      if (isSucces) {
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

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      }),
    );
  }
}
