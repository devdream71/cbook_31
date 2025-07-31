part of '../sales_return_view.dart';

class FieldPortion extends StatelessWidget {
  const FieldPortion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesReturnController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ///====================== cash ==============================///

        //sell return amount //cash
        controller.isCash && controller.isAmount
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Amount',
                      readOnly: true,
                      controller:
                          TextEditingController(text: controller.addAmount2()),
                      onChanged: (value) {
                        Provider.of(context)<SalesReturnController>();

                        controller.amountController.text =
                            controller.addAmount2();
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        //sell return discount //cash
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Discount',
                      controller: controller.discountController,
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;

                        // Parse amount and discount safely
                        double amount =
                            double.tryParse(controller.addAmount2()) ?? 0.0;
                        double discount = double.tryParse(value) ?? 0.0;
                        double finalPayment = amount - discount;

                        controller.amountController.text =
                            finalPayment.toStringAsFixed(2);
                        controller.discountController.text = value;

                        controller.updatePaymentFromDiscount();

                        controller.notifyListeners(); // if needed to rebuild UI
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        // sell return payment //cash
        controller.isDisocunt && controller.isCash
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
                                value: controller.isDisocunt,
                                onChanged: (bool? value) {
                                  if (controller.isCash) {
                                    // Allow checking, but prevent unchecking
                                    if (value == true) {
                                      controller.isDisocunt = true;
                                      controller.notifyListeners();
                                    }
                                  } else {
                                    // Allow normal toggling when not cash
                                    controller.isDisocunt = value ?? false;
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

                    ///payment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Payment",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: 30,
                          width: 150,
                          child: AddSalesFormfield(
                            labelText: 'Payment',
                            //readOnly: true,
                            onChanged: (value) {},
                            controller: controller.amountController,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        ///====================== credit =================================///

        ////===> sell return credit ////amount
        controller.isCash == false && controller.isAmountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Amount',
                      controller:
                          TextEditingController(text: controller.addAmount()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        Provider.of(context)<SalesReturnController>();
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        //sell return  //discount //credit
        controller.isCash == false && controller.isDiscountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Discount',
                      controller: controller.discountController,
                      onChanged: (value) {
                        // Update discount controller
                        controller.discountController.text = value;
                        
                        // Update credit payment calculation
                        controller.updateCreditPaymentFromDiscount();
                      },
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 3,
        ),

        ///sell return payment /// credit

        controller.isCash == false
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
                              value: controller.isSubTotalCredit,
                              onChanged: (bool? value) {
                                controller.isSubTotalCredit = value ?? false;
                                controller.notifyListeners();
                              },
                            ),
                          ),
                        ),
                        const Text("",
                            style:
                                TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Payment",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: 30,
                          width: 150,
                          child: AddSalesFormfield(
                            labelText: 'Payment',
                            //readOnly: true,
                            onChanged: (value) {},
                            controller: TextEditingController(text: controller.getCreditPaymentAmount()),
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

