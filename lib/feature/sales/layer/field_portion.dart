part of '../sales_view.dart';

class FieldPortion extends StatefulWidget {
  const FieldPortion({super.key});

  @override
  State<FieldPortion> createState() => _FieldPortionState();
}

class _FieldPortionState extends State<FieldPortion> {
  
  late TextEditingController taxAmountController;
  TextEditingController totalAmountController = TextEditingController();

  String? selectedTaxId;

  @override
  void initState() {
    super.initState();
    taxAmountController = TextEditingController();
    //totalAmountController = TextEditingController();
    totalAmountController.text = '0.00'; // Initial value

    final controller = context.read<SalesController>();

    controller.addListener(() {
      taxAmountController.text = controller.taxAmount.toStringAsFixed(2);
      totalAmountController.text = controller.totalAmount;
      setState(() {}); // Rebuild to reflect changes in UI
    });

    taxAmountController.text = controller.taxAmount.toStringAsFixed(2);
    totalAmountController.text = controller.totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();

    String? selectedTaxName;

    //final discoust = controller.receivedMoneyController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 1st Row: Amount //cash
        controller.isAmount && controller.isCash
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Amount",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    hPad5,
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        // controller: controller.amountController,
                        onChanged: (value) {
                          Provider.of(context)<SalesController>();
                          controller.amountController.text =
                              controller.addAmount2();
                        },
                        controller: TextEditingController(
                            text: controller.addAmount2()),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        /////====> cash discount and percentance.
        controller.isDisocunt &&
                controller.isCash //controller.isDisocunt == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Discount",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    const SizedBox(width: 5),
                    SizedBox(
                      height: 30,
                      width: 80,
                      child: AddSalesFormfield(
                        keyboardType: TextInputType.number,
                        labelText: "Discount",
                        controller: controller.discountController,
                        onChanged: (value) {
                          //controller.updateDiscountCreditAmount(value);
                          controller.updateDiscountCashAmount(value);
                        },
                        //style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "৳",
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    SizedBox(
                      height: 30,
                      width: 80,
                      child: AddSalesFormfield(
                        labelText: "%",
                        controller: controller.percentController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          debugPrint("cbook");
                          // controller.updateDiscountCreditPercent(value);
                          controller.updateDiscountCashPercent(value);
                        },
                        //style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "%",
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // const SizedBox(
        //   height: 5,
        // ),

        // //cash ////tax and percentace
        controller.isVatTax && controller.isCash
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("TAX/VAT",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 80,
                      child: Consumer<TaxProvider>(
                        builder: (context, taxProvider, child) {
                          if (taxProvider.isLoading) {
                            return const Center(
                                child:
                                    SizedBox()); //CircularProgressIndicator()
                          }

                          if (taxProvider.taxList.isEmpty) {
                            return const Center(
                              child: Text(
                                'No tax options available.',
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }
                          return SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownTwo(
                                  hint: '', //Select VAT/TAX
                                  items: taxProvider.taxList
                                      .map((tax) => tax.percent) //${tax.name} -
                                      .toList(),

                                  width: double.infinity,
                                  height: 30,
                                  selectedItem: selectedTaxName,

                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedTaxName = newValue;

                                      final nameOnly =
                                          newValue?.split(" - ").first;

                                      final selected =
                                          taxProvider.taxList.firstWhere(
                                        (tax) => tax.name == nameOnly,
                                        orElse: () => taxProvider.taxList.first,
                                      );

                                      selectedTaxId = selected.id.toString();

                                      controller.selectedTaxPercent =
                                          double.tryParse(selected.percent);

                                      controller.taxPercent =
                                          controller.selectedTaxPercent ?? 0.0;

                                      controller.selectedTaxId =
                                          selected.id.toString();
                                      controller.selectedTaxPercent =
                                          double.tryParse(selected.percent);

                                      // controller.updateTaxPaecentId(
                                      //     '${selectedTaxId}_${controller.selectedTaxPercent}');

                                      /// ✅ Add these lines for calculation:
                                      controller.calculateTaxCash();
                                      controller.calculateTotalCash();

                                      final taxPercent =
                                          (controller.selectedTaxPercent ?? 0)
                                              .toStringAsFixed(0);
                                      controller.updateTaxPaecentId(
                                          '${selectedTaxId}_$taxPercent');

                                      debugPrint(
                                          'tax_percent: "${controller.taxPercentValue}"');
                                      debugPrint(
                                          "Selected Tax ID: $selectedTaxId");
                                      debugPrint(
                                          "Selected Tax Percent: ${controller.selectedTaxPercent}");

                                      controller.selectTotalTaxDropdown(
                                          double.parse(controller.totalAmount),
                                          newValue);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 3),

                    ///tax/vat amount ==>
                    Consumer<SalesController>(
                      builder: (context, controller, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          taxAmountController.text =
                              controller.taxAmount.toStringAsFixed(2);
                        });
                        return SizedBox(
                          width: 80,
                          child: AddSalesFormfield(
                            // controller: taxAmountController,
                            controller: TextEditingController(
                                text: controller.totalTaxAmountl!
                                        .toStringAsFixed(2) ??
                                    ""),
                            keyboardType: TextInputType.number,
                            //readOnly: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // ///cash /// adjust total
        controller.isDisocunt && controller.isCash
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<SalesController>(
                      builder: (context, controller, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          totalAmountController.text = controller.totalAmount;
                        });

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Adjust Total",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            const SizedBox(width: 5),
                            SizedBox(
                              height: 30,
                              width: 163,
                              child: AddSalesFormfield(
                                readOnly: true,
                                controller: totalAmountController,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // //==cash ///recived
        controller.isReciptType && controller.isCash
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          //color: Colors.pink,
                          child: SizedBox(
                              height: 30,
                              child: Checkbox(
                                value: controller.isReceived,
                                onChanged: (bool? value) {
                                  if (controller.isCash) {
                                    // Allow checking, but prevent unchecking
                                    if (value == true) {
                                      controller.isReceived = true;
                                      controller.notifyListeners();
                                      debugPrint("cash recived. ${controller.isReceived}");
                                    }
                                  } else {
                                    // Allow normal toggling when not cash
                                    controller.isReceived = value ?? false;
                                    controller.notifyListeners();
                                  }
                                },
                              )),
                        ),
                        const Text("",
                            style:
                                TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Received",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: 30,
                          width: 163,
                          child: AddSalesFormfield(
                            readOnly: true,
                            onChanged: (value) {
                              Provider.of(context)<SalesController>();
                            },
                            controller: TextEditingController(
                                text: controller.totalAmount),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // hPad10,
        ////===================///////////
        ////====> credit amount <<<============
        controller.isCash == false && controller.isPreviousRecipt == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Amount",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    hPad5,
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        // controller: controller.receivedMoneyController,
                        onChanged: (value) {
                          Provider.of(context)<SalesController>();
                          controller.amountController.text =
                              controller.addAmount();
                        },
                        controller:
                            TextEditingController(text: controller.addAmount()),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        ////==============================================>>> credit

        // controller.isCash == false ? vPad5 : const SizedBox.shrink(),

        // /////credit discount <==============

        controller.isCash == false && controller.isDisocunt == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Discount",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    const SizedBox(width: 5),
                    SizedBox(
                      height: 30,
                      width: 80,
                      child: AddSalesFormfield(
                        keyboardType: TextInputType.number,
                        labelText: "Discount",
                        controller: controller.discountController,
                        onChanged: (value) {
                          controller.updateDiscountCreditAmount(value);
                        },
                        //style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "৳",
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    SizedBox(
                      height: 30,
                      width: 80,
                      child: AddSalesFormfield(
                        labelText: "%",
                        controller: controller.percentController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          controller.updateDiscountCreditPercent(value);
                        },
                        //style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "%",
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // const SizedBox(
        //   height: 5,
        // ),

        // //controller.isVatTax && controller.isCash
        controller.isCash == false && controller.isVatTax
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("TAX/VAT",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    const SizedBox(width: 5),
                    SizedBox(
                      child: Consumer<TaxProvider>(
                        builder: (context, taxProvider, child) {
                          if (taxProvider.isLoading) {
                            return const Center(
                                child:
                                    SizedBox()); //CircularProgressIndicator()
                          }

                          if (taxProvider.taxList.isEmpty) {
                            return const Center(
                              child: Text(
                                'No tax options available.',
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }
                          return SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownTwo(
                                  hint: '', //Select VAT/TAX
                                  items: taxProvider.taxList
                                      .map((tax) => tax.percent) //${tax.name} -
                                      .toList(),

                                  width: double.infinity,
                                  height: 30,
                                  selectedItem: selectedTaxName,

                                  onChanged: (newValue) {
                                    debugPrint(
                                        "Selected raw value from dropdown: $newValue");
                                    setState(() {
                                      selectedTaxName = newValue;

                                      // Find tax by percent
                                      final selected =
                                          taxProvider.taxList.firstWhere(
                                        (tax) => tax.percent == newValue,
                                        orElse: () => taxProvider.taxList.first,
                                      );

                                      // Store ID and Percent
                                      controller.selectedTotalTaxId =
                                          selected.id.toString();
                                      controller.selectedTotalTaxPercent =
                                          double.tryParse(selected.percent)!;

                                      // Calculate tax/total
                                      controller.taxPercent =
                                          controller.selectedTotalTaxPercent;
                                      controller.calculateTax();
                                      controller.calculateTotal();

                                      // Print required format: tax_percent: "3_12.0"

                                      controller.updateTotalTaxId(
                                          '${controller.selectedTotalTaxId}_${controller.selectedTotalTaxPercent}');
                                      debugPrint(
                                          'tax_percent: "${controller.taxPercentValue}"'); // ✅ This is what you want

                                      controller.selectTotalCreditTaxDropdown(
                                          double.parse(controller.totalAmount2),
                                          newValue);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 3),

                    ///tax/vat amount ==>
                    Consumer<SalesController>(
                      builder: (context, controller, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          taxAmountController.text =
                              controller.taxAmount.toStringAsFixed(2);
                        });

                        return SizedBox(
                          width: 80,
                          child: AddSalesFormfield(
                            // controller: taxAmountController,
                            controller: TextEditingController(
                                text: controller.totalTaxAmountl!
                                        .toStringAsFixed(2) ??
                                    ""),
                            keyboardType: TextInputType.number,
                            //readOnly: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // const SizedBox(
        //   height: 5,
        // ),

        // ////====>>> credit adjust toatl <<<<=======
        controller.isCash == false && controller.isBillTotal == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<SalesController>(
                      builder: (context, controller, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          totalAmountController.text = controller.totalAmount2;
                        });

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Adjust Total",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            const SizedBox(width: 5),
                            SizedBox(
                              height: 30,
                              width: 163,
                              child: AddSalesFormfield(
                                //readOnly: true,
                                controller: totalAmountController,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // const SizedBox(
        //   height: 5,
        // ),

        // ///credit recived //// need wo
        controller.isCash == false && controller.isReturn == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 25,
                          child: Checkbox(
                            value: controller.isOnlineMoneyChecked,
                            onChanged: (bool? value) {
                              controller.updateOnlineMoney();
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Received",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: 30,
                          width: 163,
                          child: AddSalesFormfield(
                            controller: controller.receivedAmountController,
                            // style: const TextStyle(
                            //     fontSize: 12, color: Colors.black),
                            ///////======////// need to work.
                            readOnly: controller
                                .isOnlineMoneyChecked, // ✅ Read-only when checked

                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (!controller.isOnlineMoneyChecked) {
                                controller.receivedAmountController.text =
                                    value; // ✅ Allow manual input
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
