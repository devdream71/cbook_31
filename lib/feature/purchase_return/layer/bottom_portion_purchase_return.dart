import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/purchase_return/controller/purchase_return_controller.dart';
import 'package:cbook_dt/feature/purchase_return/provider/purchase_return_provider.dart';
import 'package:cbook_dt/feature/sales/widget/custom_box.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomPortionPurchaseReturn extends StatefulWidget {
  final String saleType;
  final String? customerId;
  final List<InvoiceItem> invoiceItems;
  final String billNumber;
  const BottomPortionPurchaseReturn({
    super.key,
    required this.saleType,
    this.customerId,
    required this.billNumber,
    required this.invoiceItems,
  });

  @override
  State<BottomPortionPurchaseReturn> createState() =>
      _BottomPortionPurchaseReturnState();
}

class _BottomPortionPurchaseReturnState
    extends State<BottomPortionPurchaseReturn> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseReturnController>();

    //final colorScheme = Theme.of(context).colorScheme;
    debugPrint("its bottom portion page");
    debugPrint(widget.saleType);
    debugPrint(widget.customerId);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            hPad5,

            ///=====>View A4
            // InkWell(
            //   onTap: () {
            //     if (controller.purchaseReturnItemModel.isEmpty) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           backgroundColor: Colors.red,
            //           duration: Duration(seconds: 1),
            //           content: Text("No Item added"),
            //         ),
            //       );
            //     } else {
            //       debugPrint(
            //           "return item length ${controller.purchaseReturnItemModel.length}");
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
            //           builder: (context) =>
            //               InvoiceScreen(items: invoiceItems),
            //         ),
            //       );
            //     }
            //   },
            //   child: const CustomBox(
            //     color: Colors.white,
            //     textColor: Colors.black,
            //     text: "View A4",
            //   ),
            // ),

            hPad5,

            ///=====>View A5
            // InkWell(
            //   onTap: () {
            //     if (controller.purchaseReturnItemModel.isEmpty) {
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

            //       debugPrint("item name   ");

            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) =>
            //                   InvoiceA5(items: invoiceItems)));
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
            //         content: Text("NO function called"),
            //       ),
            //     );
            //   },
            //   child: const CustomBox(
            //     color: Colors.white,
            //     textColor: Colors.black,
            //     text: "Save & View",
            //   ),
            // ),

            //printing pdf
            // ElevatedButton.icon(
            //   onPressed: () {
            //     //_viewPDFGenPrinting();
            //     // debugPrint('vieww pdf called');
            //     // if (controller.saleItem.isEmpty) {
            //     //             ScaffoldMessenger.of(context).showSnackBar(
            //     //               const SnackBar(
            //     //                 backgroundColor: Colors.red,
            //     //                 duration: Duration(seconds: 1),
            //     //                 content: Text("No Item added"),
            //     //               ),
            //     //             );
            //     //           } else {
            //     //             debugPrint(
            //     //                 "return item length ${controller.saleItem.length}");

            //     //             final String finalCustomerName = controller.isCash
            //     //                 ? 'Cash'
            //     //                 : controller.customerNameController.text;

            //     //             final String billPersion = controller.billPerson.text;

            //     //             final String discountPercent =
            //     //                 controller.percentController.text;
            //     //             final String discountAmount =
            //     //                 controller.discountController.text;

            //     //             // Get selected tax
            //     //             final String selectedTaxIdPercent = controller
            //     //                         .selectedTotalTaxId !=
            //     //                     null
            //     //                 ? '${controller.selectedTotalTaxId}_${controller.selectedTotalTaxPercent}'
            //     //                 : '';

            //     //              // Get tax amount
            //     //             final String taxAmount =
            //     //                 controller.totalTaxAmountl?.toStringAsFixed(2) ??
            //     //                     '0.00';

            //     //             //helper function
            //     //             int _toInt(dynamic value) {
            //     //               if (value is int) return value;
            //     //               if (value is double) return value.toInt();
            //     //               if (value is String)
            //     //                 return double.tryParse(value)?.toInt() ?? 0;
            //     //               return 0;
            //     //             }

            //     //             List<InvoiceItem> invoiceItems = (controller.isCash
            //     //                     ? controller.itemsCash
            //     //                     : controller.itemsCredit)
            //     //                 .map((item) {
            //     //               return InvoiceItem(
            //     //                 itemName: item.itemName ?? "",
            //     //                 unit: item.unit ?? "PC",
            //     //                 quantity: int.tryParse(item.quantity ?? "0") ?? 0,
            //     //                 amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
            //     //                     (double.tryParse(item.mrp ?? "0") ?? 0.0),
            //     //                 discount: double.tryParse(
            //     //                         controller.discountController.text) ??
            //     //                     0.0,
            //     //                 itemDiscountAmount: _toInt(item.discountAmount),
            //     //                 itemDiscountPercentace:
            //     //                     _toInt(item.discountPercentance),
            //     //                 itemVatTaxAmount: _toInt(item.vatAmount),
            //     //                 itemvatTaxPercentace: _toInt(item.vatPerentace),
            //     //                 customerName: _toInt(item.vatPerentace),
            //     //               );
            //     //             }).toList();

            //     //             Navigator.push(
            //     //               context,
            //     //               MaterialPageRoute(
            //     //                 builder: (context) => NewInvoicePage(
            //     //                   items: invoiceItems,
            //     //                   billNo: widget.billNo,
            //     //                   customerName: finalCustomerName,
            //     //                   billPersion: billPersion,
            //     //                   discountAmount: discountAmount,
            //     //                   discountPercent: discountPercent,
            //     //                   taxAmount: taxAmount,
            //     //                   taxIdPercent: selectedTaxIdPercent,
            //     //                 ),
            //     //               ),
            //     //             );
            //     //           }
            //   },
            //   icon: const Icon(Icons.picture_as_pdf, size: 18),
            //   label: const Text(
            //     "View PDF",
            //     style: TextStyle(fontSize: 12),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            //     minimumSize: const Size(0, 0),
            //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(5), // Rounded corners
            //     ),
            //   ),
            // ),

            hPad5,
            /////====
            /// save <=====
            ////===
            InkWell(
              onTap: () async {
                if (widget.billNumber.trim().isEmpty ||
                    controller.demoPurchaseReturnModelList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Bill number cannot be empty or no item added.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final amount = controller.isCash
                    ? controller.addAmount2()
                    : controller.addAmount();
                final total = controller.isCash
                    ? controller.totalAmount()
                    : controller.totalAmount2();
                final discount = controller.discountController.text;

                final isSuccess = await controller.storePurchaseReturn(
                  amount: amount,
                  customerId: widget.customerId ?? "cash",
                  saleType: widget.saleType,
                  discount: discount,
                  billNo: widget.billNumber,
                  total: total,
                );

                if (isSuccess.isNotEmpty) {
                  // ✅ Clear controllers and lists BEFORE popping
                  controller.itemsCashReuturn.clear();
                  controller.itemsCreditReturn.clear();
                  controller.purchaseItemReturn.clear();
                  controller.reductionQtyList.clear();
                  controller.demoPurchaseReturnModelList.clear();
                  controller.discountController.clear();
                  controller.discountAmountController.clear();
                  controller.customerNameController.clear();

                  // Refresh purchase return list in provider
                  await Provider.of<PurchaseReturnProvider>(context,
                          listen: false)
                      .fetchPurchaseReturns();

                  Navigator.pop(context);

                  // Show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSuccess),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  // ✅ Pop page after clearing state
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSuccess),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 1),
                    ),
                  );
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
    );
  }
}
