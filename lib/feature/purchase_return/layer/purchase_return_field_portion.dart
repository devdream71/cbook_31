part of '../presentation/purchase_return_view.dart';

class FieldPortion extends StatefulWidget {
  const FieldPortion({super.key});

  @override
  State<FieldPortion> createState() => _FieldPortionState();
}

class _FieldPortionState extends State<FieldPortion> {
  bool isReceivedChecked = false;
  bool isReceivedCheckedCredit = false;

  double balance = 0.0;

  final receivedController = TextEditingController();
  final receivedControllerCredit = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = context.read<PurchaseReturnController>();

    if (controller.isCash) {
      // Always checked for cash
      isReceivedChecked = true;
      _updateReceivedAmount(controller);
    } else {
      // ✅ For credit: Start unchecked with empty field for manual input
      isReceivedCheckedCredit = false;
      balance = 0.0;
      receivedControllerCredit.clear(); // Start empty for manual input
    }

    // ✅ Add listener to auto-update balance when text changes
    receivedControllerCredit.addListener(_updateBalance);
  }

  void _updateBalance() {
    final controller = context.read<PurchaseReturnController>();

    // ✅ Calculate balance: Total - Discount - Received
    double total = double.tryParse(controller.addAmount()) ?? 0.0;
    double discount =
        double.tryParse(controller.discountController.text) ?? 0.0;
    double received = double.tryParse(receivedControllerCredit.text) ?? 0.0;

    setState(() {
      balance = (total - discount) - received;
    });
  }

  void _updateReceivedAmount(PurchaseReturnController controller) {
    if (controller.isCash) {
      // For cash calculation
      double total = double.tryParse(controller.addAmount2()) ?? 0.0;
      double discount =
          double.tryParse(controller.discountController.text) ?? 0.0;
      double received = total - discount;
      receivedController.text = received.toStringAsFixed(2);
    } else {
      // ✅ For credit calculation - use addAmount() instead of addAmount2()
      double total = double.tryParse(controller.addAmount()) ?? 0.0;
      double discount =
          double.tryParse(controller.discountController.text) ?? 0.0;
      double received = total - discount;
      receivedControllerCredit.text = received.toStringAsFixed(2);

      // ✅ Update balance when auto-calculating
      _updateBalance();
    }
  }

  @override
  void dispose() {
    // ✅ Remove listener before disposing
    receivedControllerCredit.removeListener(_updateBalance);
    receivedController.dispose();
    receivedControllerCredit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseReturnController>();

    // If it's cash, always keep checkbox checked and auto-calculate
    if (controller.isCash) {
      isReceivedChecked = true;
      double total = double.tryParse(controller.addAmount2()) ?? 0.0;
      double discount =
          double.tryParse(controller.discountController.text) ?? 0.0;
      double received = total - discount;
      receivedController.text = received.toStringAsFixed(2);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //purchase return amount //cash
        controller.isCash && controller.isAmount
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Total",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 38,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Total",
                      controller:
                          TextEditingController(text: controller.addAmount2()),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                        controller.amountController.text =
                            controller.addAmount2();
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(height: 4),

        //purchase return discount //cash
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 38,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Discount",
                      controller: controller.discountController,
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;
                        // ✅ Auto-update cash received when discount changes
                        if (controller.isCash && isReceivedChecked) {
                          setState(() {
                            _updateReceivedAmount(controller);
                          });
                        }
                        // ✅ Update balance for credit when discount changes
                        if (!controller.isCash) {
                          _updateBalance();
                        }
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(height: 4),

        // ---- Received with Checkbox for CASH ----
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: isReceivedChecked,
                    onChanged: (value) {
                      if (controller.isCash)
                        return; // Ignore taps if cash (always checked)
                      setState(() {
                        isReceivedChecked = value ?? false;
                        if (isReceivedChecked) {
                          _updateReceivedAmount(controller);
                        } else {
                          receivedController.clear();
                        }
                      });
                    },
                  ),
                  const Text(
                    "Received",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  hPad5,
                  SizedBox(
                    height: 38,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Received',
                      controller: receivedController,
                      readOnly:
                          true, // ✅ Disable editing for cash (auto-calculated)
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(height: 4),

        ////===> purchase return credit ////amount
        controller.isCash == false && controller.isAmountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Total",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 38,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Total',
                      controller:
                          TextEditingController(text: controller.addAmount()),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                        // ✅ Update credit received if checkbox is checked when total changes
                        if (isReceivedCheckedCredit) {
                          setState(() {
                            _updateReceivedAmount(controller);
                          });
                        } else {
                          // ✅ Update balance even if not auto-calculating received
                          _updateBalance();
                        }
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(height: 4),

        //credit purchase return discount
        controller.isCash == false && controller.isDiscountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 38,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Discount",
                      controller: controller.discountController,
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;
                        // ✅ Update credit received if checkbox is checked when discount changes
                        if (isReceivedCheckedCredit) {
                          setState(() {
                            _updateReceivedAmount(controller);
                          });
                        } else {
                          // ✅ Update balance even if not auto-calculating received
                          _updateBalance();
                        }
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(height: 4),

        ///purchase return received /// credit - ✅ FIXED SECTION
        controller.isCash == false && controller.isSubTotalCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: isReceivedCheckedCredit,
                    onChanged: (value) {
                      setState(() {
                        isReceivedCheckedCredit = value ?? false;
                        if (isReceivedCheckedCredit) {
                          // ✅ When checked: Auto-calculate (total - discount)
                          _updateReceivedAmount(controller);
                        } else {
                          // ✅ When unchecked: Clear field for manual input
                          receivedControllerCredit.clear();
                          balance = 0.0; // Reset balance
                        }
                      });
                    },
                  ),
                  const Text("Received",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 38,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Received",
                      controller: receivedControllerCredit,
                      // ✅ Key Fix: Use readOnly to control editing
                      readOnly: isReceivedCheckedCredit,
                      onChanged: (value) {
                        // ✅ Handle manual input when checkbox is unchecked
                        if (!isReceivedCheckedCredit) {
                          // Manual input will trigger the listener automatically
                          // No need to manually update here as listener handles it
                        }
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(height: 8),

        // ✅ Enhanced Balance Display
        controller.isCash == false && controller.isSubTotalCredit
            ? Text(
                "Balance: ৳${balance.toStringAsFixed(2)}",
                style: TextStyle(
                  color: balance >= 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}



// class FieldPortion extends StatefulWidget {
//   const FieldPortion({super.key});

//   @override
//   State<FieldPortion> createState() => _FieldPortionState();
// }

// class _FieldPortionState extends State<FieldPortion> {
//   bool isReceivedChecked = false;
//   bool isReceivedCheckedCredit = false;

//    double balance = 0.0;

//   final receivedController = TextEditingController();
//   final receivedControllerCredit = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final controller = context.read<PurchaseReturnController>();

//     if (controller.isCash) {
//       // Always checked for cash
//       isReceivedChecked = true;
//       _updateReceivedAmount(controller);
//     } else {
//       // ✅ For credit: Start unchecked with empty field for manual input
//       isReceivedCheckedCredit = false;
//       balance = 0.0;
//       receivedControllerCredit.clear(); // Start empty for manual input
//     }
//   }

//   void _updateReceivedAmount(PurchaseReturnController controller) {
//     if (controller.isCash) {
//       // For cash calculation
//       double total = double.tryParse(controller.addAmount2()) ?? 0.0;
//       double discount =
//           double.tryParse(controller.discountController.text) ?? 0.0;
//       double received = total - discount;
//       receivedController.text = received.toStringAsFixed(2);
//     } else {
//       // ✅ For credit calculation - use addAmount() instead of addAmount2()
//       double total = double.tryParse(controller.addAmount()) ?? 0.0;
//       double discount =
//           double.tryParse(controller.discountController.text) ?? 0.0;
//       double received = total - discount;
//       receivedControllerCredit.text = received.toStringAsFixed(2);
//     }
//   }


//   @override
//   void dispose() {
//     receivedController.dispose();
//     receivedControllerCredit.dispose(); // ✅ Added missing dispose
    
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<PurchaseReturnController>();

//     // If it's cash, always keep checkbox checked and auto-calculate
//     if (controller.isCash) {
//       isReceivedChecked = true;
//       double total = double.tryParse(controller.addAmount2()) ?? 0.0;
//       double discount =
//           double.tryParse(controller.discountController.text) ?? 0.0;
//       double received = total - discount;
//       receivedController.text = received.toStringAsFixed(2);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         //purchase return amount //cash
//         controller.isCash && controller.isAmount
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Total",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   hPad5,
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Total",
//                       controller:
//                           TextEditingController(text: controller.addAmount2()),
//                       onChanged: (value) {
//                         Provider.of(context)<PurchaseReturnController>();
//                         controller.amountController.text =
//                             controller.addAmount2();
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(height: 4),

//         //purchase return discount //cash
//         controller.isCash && controller.isDisocunt
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Discount",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   const SizedBox(width: 5),
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Discount",
//                       controller: controller.discountController,
//                       onChanged: (value) {
//                         TextEditingController(text: controller.totalAmount());
//                         controller.discountController.text = value;
//                         // ✅ Auto-update cash received when discount changes
//                         if (controller.isCash && isReceivedChecked) {
//                           setState(() {
//                             _updateReceivedAmount(controller);
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(height: 4),

//         // ---- Received with Checkbox for CASH ----
//         controller.isCash && controller.isDisocunt
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Checkbox(
//                     value: isReceivedChecked,
//                     onChanged: (value) {
//                       if (controller.isCash)
//                         return; // Ignore taps if cash (always checked)
//                       setState(() {
//                         isReceivedChecked = value ?? false;
//                         if (isReceivedChecked) {
//                           _updateReceivedAmount(controller);
//                         } else {
//                           receivedController.clear();
//                         }
//                       });
//                     },
//                   ),
//                   const Text(
//                     "Received",
//                     style: TextStyle(fontSize: 12, color: Colors.black),
//                   ),
//                   hPad5,
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: 'Received',
//                       controller: receivedController,
//                       readOnly:
//                           true, // ✅ Disable editing for cash (auto-calculated)
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

            

//         const SizedBox(height: 4),

//         ////===> purchase return credit ////amount
//         controller.isCash == false && controller.isAmountCredit
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Total",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   hPad5,
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: 'Total',
//                       controller:
//                           TextEditingController(text: controller.addAmount()),
//                       onChanged: (value) {
//                         Provider.of(context)<PurchaseReturnController>();
//                         // ✅ Update credit received if checkbox is checked when total changes
//                         if (isReceivedCheckedCredit) {
//                           setState(() {
//                             _updateReceivedAmount(controller);
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(height: 4),

//         //credit purchase return discount
//         controller.isCash == false && controller.isDiscountCredit
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Discount",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   const SizedBox(width: 5),
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Discount",
//                       controller: controller.discountController,
//                       onChanged: (value) {
//                         TextEditingController(text: controller.totalAmount());
//                         controller.discountController.text = value;
//                         // ✅ Update credit received if checkbox is checked when discount changes
//                         if (isReceivedCheckedCredit) {
//                           setState(() {
//                             _updateReceivedAmount(controller);
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(height: 4),

//         ///purchase return received /// credit - ✅ FIXED SECTION
//         controller.isCash == false && controller.isSubTotalCredit
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Checkbox(
//                     value: isReceivedCheckedCredit,
//                     onChanged: (value) {
//                       setState(() {
//                         isReceivedCheckedCredit = value ?? false;
//                         if (isReceivedCheckedCredit) {
//                           // ✅ When checked: Auto-calculate (total - discount)
//                           _updateReceivedAmount(controller);
//                         } else {
//                           // ✅ When unchecked: Clear field for manual input
//                           receivedControllerCredit.clear();
//                         }
//                       });
//                     },
//                   ),
//                   const Text("Received",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   const SizedBox(width: 5),
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Received",
//                       controller: receivedControllerCredit,
//                       // ✅ Key Fix: Use readOnly to control editing
//                       readOnly: isReceivedCheckedCredit,
//                       onChanged: (value) {
//                         // ✅ Handle manual input when checkbox is unchecked
//                         if (!isReceivedCheckedCredit) {
//                           // Allow manual input - value is automatically set by controller
                          

                        
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         Text(
//           "Balance ${receivedControllerCredit.text}",
//           style: const TextStyle(color: Colors.black, fontSize: 12),
//         ),
//       ],
//     );
//   }
// }



// part of '../presentation/purchase_return_view.dart';

// class FieldPortion extends StatefulWidget {
//   const FieldPortion({super.key});

//   @override
//   State<FieldPortion> createState() => _FieldPortionState();
// }

// class _FieldPortionState extends State<FieldPortion> {
//   bool isReceivedChecked = false;
//   bool isReceivedCheckedCredit = false;

//   final receivedController = TextEditingController();
//   final receivedControllerCredit = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final controller = context.read<PurchaseReturnController>();

//     if (controller.isCash) {
//       // Always checked for cash
//       isReceivedChecked = true;
//       _updateReceivedAmount(controller);
//     } else {
//       // Always unchecked for credit
//       isReceivedCheckedCredit = false;
//       receivedController.clear();
//     }
//   }

//   void _updateReceivedAmount(PurchaseReturnController controller) {
//     double total = double.tryParse(controller.addAmount2()) ?? 0.0;
//     double discount =
//         double.tryParse(controller.discountController.text) ?? 0.0;
//     double received = total - discount;
//     receivedControllerCredit.text = received.toStringAsFixed(2);
//   }

//   @override
//   void dispose() {
//     receivedController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<PurchaseReturnController>();

//     // If it's cash, always keep checkbox checked
//     if (controller.isCash) {
//       isReceivedChecked = true;

//       double total = double.tryParse(controller.addAmount2()) ?? 0.0;
//       double discount =
//           double.tryParse(controller.discountController.text) ?? 0.0;
//       double received = total - discount;
//       receivedController.text = received.toStringAsFixed(2);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         //purchase return amount //cash
//         controller.isCash && controller.isAmount
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Total",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   hPad5,
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Total",
//                       controller:
//                           TextEditingController(text: controller.addAmount2()),
//                       //style: const TextStyle(fontSize: 12, color: Colors.black),
//                       onChanged: (value) {
//                         Provider.of(context)<PurchaseReturnController>();
//                         controller.amountController.text =
//                             controller.addAmount2();
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(
//           height: 4,
//         ),

//         //purchase return discount //cash
//         controller.isCash && controller.isDisocunt
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Discount",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   const SizedBox(width: 5),
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Discount",
//                       controller: controller.discountController,
//                       //style: const TextStyle(fontSize: 12, color: Colors.black),
//                       onChanged: (value) {
//                         TextEditingController(text: controller.totalAmount());
//                         controller.discountController.text = value;
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(
//           height: 4,
//         ),

//         // const SizedBox(height: 2,),

//         // purchase return Total //cash
//         // controller.isCash && controller.isDisocunt
//         //     ? Row(
//         //         mainAxisAlignment: MainAxisAlignment.end,
//         //         children: [
//         //           const Text("Received",
//         //               style: TextStyle(fontSize: 12, color: Colors.black)),
//         //           hPad5,
//         //           SizedBox(
//         //             height: 30,
//         //             width: 150,
//         //             child: AddSalesFormfield(
//         //               labelText: 'Received',
//         //               controller:
//         //                   TextEditingController(text: controller.totalAmount()),
//         //               //style: const TextStyle(fontSize: 12, color: Colors.black),
//         //               onChanged: (value) {
//         //                 Provider.of(context)<PurchaseReturnController>();
//         //               },
//         //             ),
//         //           ),
//         //         ],
//         //       )
//         //     : const SizedBox.shrink(),

//         // purchase return Total //cash
//         // ---- Received with Checkbox ----
//         controller.isCash && controller.isDisocunt
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   // Checkbox(
//                   //   value: isReceivedChecked,
//                   //   onChanged: (value) {
//                   //     setState(() {
//                   //       isReceivedChecked = value ?? false;

//                   //       if (isReceivedChecked) {
//                   //         double total =
//                   //             double.tryParse(controller.addAmount2()) ??
//                   //                 0.0; // full total before discount
//                   //         double discount = double.tryParse(
//                   //                 controller.discountController.text) ??
//                   //             0.0;
//                   //         double received = total - discount;
//                   //         receivedController.text = received.toStringAsFixed(2);
//                   //       } else {
//                   //         receivedController.clear();
//                   //       }
//                   //     });
//                   //   },
//                   // ),

//                   // Checkbox(
//                   //   value: isReceivedChecked,
//                   //   onChanged: controller.isCash
//                   //       ? null // ❌ Disable if cash
//                   //       : (value) {
//                   //           setState(() {
//                   //             isReceivedChecked = value ?? false;
//                   //             if (isReceivedChecked) {
//                   //               double total =
//                   //                   double.tryParse(controller.addAmount2()) ??
//                   //                       0.0;
//                   //               double discount = double.tryParse(
//                   //                       controller.discountController.text) ??
//                   //                   0.0;
//                   //               double received = total - discount;
//                   //               receivedController.text =
//                   //                   received.toStringAsFixed(2);
//                   //             } else {
//                   //               receivedController.clear();
//                   //             }
//                   //           });
//                   //         },
//                   // ),

//                   Checkbox(
//                     value: isReceivedChecked,
//                     onChanged: (value) {
//                       if (controller.isCash) return; // Ignore taps if cash
//                       setState(() {
//                         isReceivedChecked = value ?? false;
//                         if (isReceivedChecked) {
//                           double total =
//                               double.tryParse(controller.addAmount2()) ?? 0.0;
//                           double discount = double.tryParse(
//                                   controller.discountController.text) ??
//                               0.0;
//                           double received = total - discount;
//                           receivedController.text = received.toStringAsFixed(2);
//                         } else {
//                           receivedController.clear();
//                         }
//                       });
//                     },
//                   ),

//                   const Text(
//                     "Received",
//                     style: TextStyle(fontSize: 12, color: Colors.black),
//                   ),
//                   hPad5,
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: 'Received',
//                       controller: receivedController,
//                       //enabled: false, // Prevent manual editing
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(
//           height: 4,
//         ),

//         ////===> purchase return credit ////amount
//         controller.isCash == false && controller.isAmountCredit
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Total",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   hPad5,
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: 'Total',
//                       controller:
//                           TextEditingController(text: controller.addAmount()),
//                       //style: const TextStyle(fontSize: 12, color: Colors.black),
//                       onChanged: (value) {
//                         Provider.of(context)<PurchaseReturnController>();
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(
//           height: 4,
//         ),

//         //credit purchase return  //discount
//         controller.isCash == false && controller.isDiscountCredit
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const Text("Discount",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   const SizedBox(width: 5),
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Discount",
//                       controller: controller.discountController,
//                       onChanged: (value) {
//                         TextEditingController(text: controller.totalAmount());
//                         controller.discountController.text = value;
//                       },
//                       //style: const TextStyle(fontSize: 12, color: Colors.black),
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink(),

//         const SizedBox(
//           height: 4,
//         ),

//         ///purchase return total /// credit
//         // controller.isCash == false && controller.isSubTotalCredit
//         //     ? Row(
//         //         mainAxisAlignment: MainAxisAlignment.end,
//         //         children: [
//         //           Checkbox(
//         //             value: isReceivedChecked,
//         //             onChanged: (value) {
//         //               setState(() {
//         //                 isReceivedChecked = value ?? false;

//         //                 if (isReceivedChecked) {
//         //                   double total =
//         //                       double.tryParse(controller.addAmount2()) ??
//         //                           0.0; // full total before discount
//         //                   double discount = double.tryParse(
//         //                           controller.discountController.text) ??
//         //                       0.0;
//         //                   double received = total - discount;
//         //                   receivedController.text = received.toStringAsFixed(2);
//         //                 } else {
//         //                   receivedController.clear();
//         //                 }
//         //               });
//         //             },
//         //           ),
//         //           const Text("Received",
//         //               style: TextStyle(fontSize: 12, color: Colors.black)),
//         //           const SizedBox(width: 5),
//         //           SizedBox(
//         //             height: 30,
//         //             width: 150,
//         //             child: AddSalesFormfield(
//         //               labelText: "Received",
//         //               controller: TextEditingController(
//         //                   text: controller.totalAmount2()),
//         //               onChanged: (value) {
//         //                 Provider.of(context)<PurchaseReturnController>();
//         //               },
//         //               //style: const TextStyle(fontSize: 12, color: Colors.black),
//         //             ),
//         //           ),
//         //         ],
//         //       )
//         //     : const SizedBox.shrink(),

//         controller.isCash == false && controller.isSubTotalCredit
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Checkbox(
//                     value: isReceivedCheckedCredit,
//                     onChanged: (value) {
//                       setState(() {
//                         isReceivedCheckedCredit = value ?? false;
//                         if (isReceivedCheckedCredit) {
//                           _updateReceivedAmount(controller);
//                         } else {
//                           receivedControllerCredit.clear();
//                         }
//                       });
//                     },
//                   ),
//                   const Text("Received",
//                       style: TextStyle(fontSize: 12, color: Colors.black)),
//                   const SizedBox(width: 5),
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: AddSalesFormfield(
//                       labelText: "Received",
//                       controller: receivedControllerCredit,
//                     ),
//                   ),
//                 ],
//               )
//             : const SizedBox.shrink()
//       ],
//     );
//   }
// }
