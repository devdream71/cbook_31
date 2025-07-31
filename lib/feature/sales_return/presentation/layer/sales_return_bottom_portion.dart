// part of 'sales_return_view.dart';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/invoice/invoice.dart';
import 'package:cbook_dt/feature/invoice/invoice_a5.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/sales/widget/custom_box.dart';
import 'package:cbook_dt/feature/sales_return/controller/sales_return_controller.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomPortionSaleReturn extends StatelessWidget {
  final String saleType;
  final String? customerId;
  final List<InvoiceItem> invoiceItems;
  const BottomPortionSaleReturn({
    super.key,
    required this.saleType,
    this.customerId,
    required this.invoiceItems,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesReturnController>();
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint("its bottom portion page");
    debugPrint(saleType);
    debugPrint(customerId);

    return SingleChildScrollView(
      child: Container(
        // color: const Color(0xffeceff1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              hPad5,

              ///=====>View A4
              InkWell(
                onTap: () {
                  if (controller.saleReturnItemModel.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 1),
                        content: Text("No Item added"),
                      ),
                    );
                  } else {
                    List<InvoiceItem> invoiceItems = (controller.isCash
                            ? controller.itemsCashReuturn
                            : controller.itemsCashReuturn)
                        .map((item) {
                      return InvoiceItem(
                        itemName: item.itemName ?? "",
                        unit: item.unit ?? "PC",
                        quantity: int.tryParse(item.quantity ?? "0") ?? 0,
                        amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
                            (double.tryParse(item.mrp ?? "0") ?? 0.0),
                        discount: double.tryParse(
                                controller.discountController.text) ??
                            0.0,
                      );
                    }).toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InvoiceScreen(items: invoiceItems),
                      ),
                    );
                  }
                },
                child: const CustomBox(
                  color: Colors.white,
                  textColor: Colors.black,
                  text: "View A4",
                ),
              ),
              hPad5,

              ///=====>View A5
              // InkWell(
              //   onTap: () {
              //     if (controller.saleReturnItemModel.isEmpty) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           backgroundColor: Colors.red,
              //           duration: Duration(seconds: 1),
              //           content: Text("No Item added"),
              //         ),
              //       );
              //     } else {
              //       List<InvoiceItem> invoiceItems = (controller.isCash
              //               ? controller.itemsCashReuturn
              //               : controller.itemsCashReuturn)
              //           .map((item) {
              //         return InvoiceItem(
              //           itemName: item.itemName ?? "",
              //           unit: item.unit ?? "PC",
              //           quantity: int.tryParse(item.quantity ?? "0") ?? 0,
              //           amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
              //               (double.tryParse(item.mrp ?? "0") ?? 0.0),
              //           discount: double.tryParse(
              //                   controller.discountController.text) ??
              //               0.0,
              //         );
              //       }).toList();

              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => InvoiceA5(items: invoiceItems),
              //         ),
              //       );
              //     }

              //   },
              //   child: const CustomBox(
              //     color: Colors.white,
              //     textColor: Colors.black,
              //     text: "View A5",
              //   ),
              // ),

              hPad5,
              // InkWell(
              //   onTap: () {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         backgroundColor: Colors.red,
              //         duration: Duration(seconds: 1),
              //         content: Text("No Fuction Called"),
              //       ),
              //     );
              //   },
              //   child: const CustomBox(
              //     color: Colors.white,
              //     textColor: Colors.black,
              //     text: "Save & View",
              //   ),
              // ),
              hPad5,
              /////====
              /// save <=====
              ////===
              InkWell(
                onTap: () async {
                  debugPrint(
                      "item length demoPurchaseReturnModelList ====== > ${controller.demoPurchaseReturnModelList.length}");
                  debugPrint(
                      "item length itemsCashReuturn ====== > ${controller.itemsCashReuturn.length}");
                  debugPrint(
                      "item length ====== > ${controller.itemsCash.length}");

                  if (controller.billNoController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bill number cannot be empty'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    String amount = controller.isCash
                        ? controller.addAmount2()
                        : controller.addAmount();

                    String discount = controller.discountController.text;

                    String total = controller.isCash
                        ? controller.totalAmount()
                        : controller.totalAmount2();


                    //  final isSuccess = await controller.storeSalesReturen(
                    //       //date: date,
                    //       amount: amount,
                    //       customerId: customerId ?? "cash",
                    //       saleType: saleType,
                    //       discount: discount,
                    //       billNo: controller.billNoController.text,
                    //       total: total);    

                     ///controller.demoPurchaseReturnModelList.length
                    
                    if (controller.itemsCashReuturn.isNotEmpty ||  ////controller.itemsCashReuturn.isEmpty ///it was. ///modified.
                        controller.itemsCashReuturn.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'No item added',
                        ),
                        backgroundColor: Colors.red,
                      ));
                    } else {
                      final isSuccess = await controller.storeSalesReturen(
                          //date: date,
                          amount: amount,
                          customerId: customerId ?? "cash",
                          saleType: saleType,
                          discount: discount,
                          billNo: controller.billNoController.text,
                          total: total);

                      if (isSuccess.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                            content: Text(isSuccess),
                          ),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeView(),
                          ),
                        );

                        controller.itemsCashReuturn.clear();
                        controller.itemsCreditReturn.clear();
                        //controller.purchaseItemReturn.clear();
                        controller.reductionQtyList.clear();
                        controller.itemsCashReuturn.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 1),
                            content: Text(isSuccess),
                          ),
                        );
                      }
                    }
                  }
                },
                child: CustomBox(
                  color: AppColors.primaryColor,
                  textColor: Colors.white,
                  text: "Save",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
