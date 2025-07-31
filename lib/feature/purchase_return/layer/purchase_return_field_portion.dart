part of '../presentation/purchase_return_view.dart';

class FieldPortion extends StatelessWidget {
  const FieldPortion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseReturnController>();

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
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Total",
                      controller:
                          TextEditingController(text: controller.addAmount2()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
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

        const SizedBox(
          height: 4,
        ),

        //purchase return discount //cash
        controller.isCash && controller.isDisocunt
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
                      labelText: "Discount",
                      controller: controller.discountController,
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        // const SizedBox(height: 2,),

        // purchase return Total //cash
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Received",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Received',
                      controller:
                          TextEditingController(text: controller.totalAmount()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        ////===> purchase return credit ////amount
        controller.isCash == false && controller.isAmountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Total",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Total',
                      controller:
                          TextEditingController(text: controller.addAmount()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        //credit purchase return  //discount
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
                      labelText: "Discount",
                      controller: controller.discountController,
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;
                      },
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 4,
        ),

        ///purchase return total /// credit
        controller.isCash == false && controller.isSubTotalCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Received",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Received",
                      controller: TextEditingController(
                          text: controller.totalAmount2()),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                      },
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
