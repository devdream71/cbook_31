import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/new_pdfview.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/invoice/invoice.dart';
import 'package:cbook_dt/feature/invoice/invoice_a5.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/custom_box.dart';

class BottomPortion extends StatelessWidget {
  final String saleType;
  final String? customerId;
  final List<InvoiceItem> invoiceItems;
  const BottomPortion({
    super.key,
    required this.saleType,
    this.customerId,
    required this.invoiceItems,
  });

  @override
  Widget build(BuildContext context) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final controller = context.watch<SalesController>();
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 5,
                  ),

                  //pdf share =====>
                  ElevatedButton.icon(
                    onPressed: () {
                      //_viewPDF();
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text(
                      "Share PDF",
                      style: TextStyle(fontSize: 10),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5), // Rounded corners
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 3,
                  ),

                  //printing pdf
                  ElevatedButton.icon(
                    onPressed: () {
                      //_viewPDFGenPrinting();
                      debugPrint('vieww pdf called');
                    }, //_viewPDF
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text(
                      "View PDF",
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5), // Rounded corners
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  ///here new view a4 is working.
                  InkWell(
                    onTap: () {
                      if (controller.saleItem.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                            content: Text("No Item added"),
                          ),
                        );
                      } else {
                        debugPrint(
                            "return item length ${controller.saleItem.length}");

                        final String finalCustomerName = controller.isCash
                            ? 'Cash'
                            : controller.customerNameController.text;

                        final String billPersion = controller.billPerson.text;

                        final String discountPercent =
                            controller.percentController.text;
                        final String discountAmount =
                            controller.discountController.text;

                        // Get selected tax
                        final String selectedTaxIdPercent = controller
                                    .selectedTotalTaxId !=
                                null
                            ? '${controller.selectedTotalTaxId}_${controller.selectedTotalTaxPercent}'
                            : '';

// Get tax amount
                        final String taxAmount =
                            controller.totalTaxAmountl?.toStringAsFixed(2) ??
                                '0.00';

                        //helper function
                        int _toInt(dynamic value) {
                          if (value is int) return value;
                          if (value is double) return value.toInt();
                          if (value is String)
                            return double.tryParse(value)?.toInt() ?? 0;
                          return 0;
                        }

                        List<InvoiceItem> invoiceItems = (controller.isCash
                                ? controller.itemsCash
                                : controller.itemsCredit)
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
                            itemDiscountAmount: _toInt(item.discountAmount),
                            itemDiscountPercentace:
                                _toInt(item.discountPercentance),
                            itemVatTaxAmount: _toInt(item.vatAmount),
                            itemvatTaxPercentace: _toInt(item.vatPerentace),
                            customerName: _toInt(item.vatPerentace),
                          );
                        }).toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewInvoicePage(
                              items: invoiceItems,
                              customerName: finalCustomerName,
                              billPersion: billPersion,
                              discountAmount: discountAmount,
                              discountPercent: discountPercent,
                              taxAmount: taxAmount,
                              taxIdPercent: selectedTaxIdPercent,
                            ),
                          ),
                        );
                      }
                    },
                    child: const CustomBox(
                      color: Colors.white,
                      textColor: Colors.black,
                      text: "New View A4",
                    ),
                  ),

//               hPad5,

//               ///=====>View A4
//               InkWell(
//                 onTap: () {
//                   if (controller.saleItem.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         backgroundColor: Color.fromARGB(255, 206, 206, 206),
//                         duration: Duration(seconds: 1),
//                         content: Text("No Item added"),
//                       ),
//                     );
//                   } else {
//                     debugPrint(
//                         "return item length ${controller.saleItem.length}");

//                     List<InvoiceItem> invoiceItems = (controller.isCash
//                             ? controller.itemsCash
//                             : controller.itemsCredit)
//                         .map((item) {
//                       return InvoiceItem(
//                         customerName:
//                             customerProvider.selectedCustomer?.type == 'cash'
//                                 ? 'Cash'
//                                 : controller.customerNameController.text,
//                         itemName: item.itemName ?? "",
//                         unit: item.unit ?? "PC",
//                         quantity: int.tryParse(item.quantity ?? "0") ?? 0,
//                         amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
//                             (double.tryParse(item.mrp ?? "0") ?? 0.0),
//                         discount: double.tryParse(
//                                 controller.discountController.text) ??
//                             0.0,
//                       );
//                     }).toList();

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => InvoiceScreen(
//                           items: invoiceItems,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//                 child: const CustomBox(
//                   color: Colors.white,
//                   textColor: Colors.black,
//                   text: "View A4",
//                 ),
//               ),
//               hPad5,

//               ///=====>View A5
//               InkWell(
//                 onTap: () {
//                   if (controller.saleItem.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         backgroundColor: Colors.red,
//                         duration: Duration(seconds: 1),
//                         content: Text("No Item added"),
//                       ),
//                     );
//                   } else {
//                     List<InvoiceItem> invoiceItems = (controller.isCash
//                             ? controller.itemsCash
//                             : controller.itemsCash)
//                         .map((item) {
//                       return InvoiceItem(
//                         itemName: item.itemName ?? "",
//                         unit: item.unit ?? "PC",
//                         quantity: int.tryParse(item.quantity ?? "0") ?? 0,
//                         amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
//                             (double.tryParse(item.mrp ?? "0") ?? 0.0),
//                         discount: double.tryParse(
//                                 controller.discountController.text) ??
//                             0.0,
//                       );
//                     }).toList();

//                     debugPrint("item name   ");

//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 InvoiceA5(items: invoiceItems)));
//                   }
//                 },
//                 child: const CustomBox(
//                   color: Colors.white,
//                   textColor: Colors.black,
//                   text: "View A5",
//                 ),
//               ),
//               hPad5,
//               InkWell(
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       backgroundColor: Colors.red,
//                       duration: Duration(seconds: 1),
//                       content: Text("No function called"),
//                     ),
//                   );
//                 },
//                 child: const CustomBox(
//                   color: Colors.white,
//                   textColor: Colors.black,
//                   text: "Save & View",
//                 ),
//               ),
//               hPad5,

                  const SizedBox(
                    width: 6,
                  ),

                  //download
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     //_viewPDFDownload();
                  //   }, //
                  //   icon: const Icon(
                  //     Icons.download,
                  //     size: 18,
                  //   ),
                  //   label: const Text(
                  //     "Download PDF",
                  //     style: TextStyle(fontSize: 12),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.green,
                  //     foregroundColor: Colors.white,
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 8, vertical: 6),
                  //     minimumSize: const Size(0, 0),
                  //     tapTargetSize:
                  //         MaterialTapTargetSize.shrinkWrap,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(
                  //           5), // Rounded corners
                  //     ),
                  //   ),
                  // ),

                  //settings
                ],
              ),

              /// save <=====

              InkWell(
                onTap: () async {
                  var date = controller.formattedDate;

                  String amount = controller.isCash
                      ? controller.addAmount2()
                      : controller.addAmount();

                  debugPrint(' cash or credit ===>  ${controller.isCash}');  

                  String discount = controller.discountController.toString();

                  String total = controller.isCash
                      ? controller.totalAmount
                      : controller.totalAmount2;

                  debugPrint("amount =========>>>>====> $amount");

                  debugPrint(
                      "amount =========>>>>====> ${controller.billController.text}");

                  int paymentOutValue = 0;

                  if (controller.isCash) {
                    paymentOutValue = 1;
                  } else if (controller.isReturn &&
                      controller.isOnlineMoneyChecked) {
                    paymentOutValue = 1;
                  } else {
                    paymentOutValue = 0;
                  }

                  if (controller.saleItem.isEmpty ||
                      controller.billController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        'No Item added or no bill no',
                      ),
                      backgroundColor: Colors.red,
                    ));
                  } else {
                    bool isSuccess = await controller.storeSales(
                      context,
                      date: date,
                      amount: amount,
                      // customerId: customerId ?? "cash",
                      customerId: controller.getCustomerId(context),

                      saleType: saleType,
                      billNo: controller.billController.text,
                      total: total,
                      discount: controller.discountAmount.text,
                      discountPercent: controller.discountPercentance.text,
                      taxAmount: controller.totalAmount,
                      taxPercent: controller.taxPercent,
                      paymentOut: paymentOutValue,
                    );

                    if (isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                          content: Text("Sale. Successfully Save,"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                          content: Text("Not uloaded Sales"),
                        ),
                      );
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
