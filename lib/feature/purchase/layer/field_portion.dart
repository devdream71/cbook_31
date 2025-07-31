part of '../purchase_view.dart';

class FieldPortion extends StatelessWidget {
  const FieldPortion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseController>();

    return 
    
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1st Row: Amount
        controller.isCash && controller.isAmount
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 25,
                    width: 150,
                    child: TextField(
                      controller: controller.amountController,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        controller.isCash && controller.isAmount
            ? vPad5
            : const SizedBox.shrink(),

        // 2nd Row: Discount
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 25,
                    width: 71,
                    child: TextField(
                      controller: controller.discountPercentageController,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "%",
                        hintStyle: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                  hPad2,
                  SizedBox(
                    height: 25,
                    width: 71,
                    child: TextField(
                      controller: controller.discountAmountController,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Total Amount",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12),
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        controller.isCash && controller.isDisocunt
            ? hPad5
            : const SizedBox.shrink(),

        // 3rd Row: Amount >>>>>>>> ======== its need next time
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 25,
                    width: 150,
                    child: TextField(
                      controller: controller.amountController2,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        controller.isCash && controller.isDisocunt
            ? vPad5
            : const SizedBox.shrink(),

        
        // 1st Row: Amount ////====> credit =====>
        controller.isCash == false && controller.isAmountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 25,
                    width: 150,
                    child: TextField(
                      controller: controller.amountCreditController,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        controller.isCash == false && controller.isAmountCredit
            ? vPad5
            : const SizedBox.shrink(),

        // 2nd Row: Discount
        controller.isCash == false && controller.isDiscountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 25,
                    width: 71,
                    child: TextField(
                      controller: controller.discountPercentageCreditController,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "%",
                        hintStyle: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                  hPad2,
                  SizedBox(
                    height: 25,
                    width: 71,
                    child: TextField(
                      controller: controller.discountAmountController,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Amount",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12),
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        controller.isCash == false && controller.isDiscountCredit
            ? hPad5
            : const SizedBox.shrink(),

        // 3rd Row: Amount
        controller.isCash == false && controller.isDiscountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 25,
                    width: 150,
                    child: TextField(
                      controller: controller.amountCreditController2,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        controller.isCash == false && controller.isDiscountCredit
            ? vPad5
            : const SizedBox.shrink(),

        
      ],
    );
  }
}
