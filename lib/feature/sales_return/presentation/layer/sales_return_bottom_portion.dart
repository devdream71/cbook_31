// part of 'sales_return_view.dart';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/new_pdfview.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/invoice/invoice.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/sales/widget/custom_box.dart';
import 'package:cbook_dt/feature/sales_return/controller/sales_return_controller.dart';
import 'package:cbook_dt/feature/sales_return/provider/sale_return_provider.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomPortionSaleReturn extends StatelessWidget {
  final String saleType;
  final String? customerId;
  final String billNo;
  final List<InvoiceItem> invoiceItems;
  const BottomPortionSaleReturn({
    super.key,
    required this.saleType,
    this.customerId,
    required this.invoiceItems,
    required this.billNo
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesReturnController>();
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint("its bottom portion page");
    debugPrint(saleType);
    debugPrint(customerId);

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
               

            //printing pdf
                ElevatedButton.icon(
                  onPressed: () {
                    //_viewPDFGenPrinting();
                    // debugPrint('vieww pdf called');
                    
                    // if (controller.saleItem.isEmpty) {
                    //             ScaffoldMessenger.of(context).showSnackBar(
                    //               const SnackBar(
                    //                 backgroundColor: Colors.red,
                    //                 duration: Duration(seconds: 1),
                    //                 content: Text("No Item added"),
                    //               ),
                    //             );
                    //           } else {
                    //             debugPrint(
                    //                 "return item length ${controller.saleItem.length}");

                    //             final String finalCustomerName = controller.isCash
                    //                 ? 'Cash'
                    //                 : controller.customerNameController.text;

                    //             final String billPersion = controller.billPerson.text;

                    //             final String discountPercent =
                    //                 controller.percentController.text;
                    //             final String discountAmount =
                    //                 controller.discountController.text;

                    //             // Get selected tax
                    //             final String selectedTaxIdPercent = controller
                    //                         .selectedTotalTaxId !=
                    //                     null
                    //                 ? '${controller.selectedTotalTaxId}_${controller.selectedTotalTaxPercent}'
                    //                 : '';

                    //              // Get tax amount
                    //             final String taxAmount =
                    //                 controller.totalTaxAmountl?.toStringAsFixed(2) ??
                    //                     '0.00';

                    //             //helper function
                    //             int _toInt(dynamic value) {
                    //               if (value is int) return value;
                    //               if (value is double) return value.toInt();
                    //               if (value is String)
                    //                 return double.tryParse(value)?.toInt() ?? 0;
                    //               return 0;
                    //             }

                    //             List<InvoiceItem> invoiceItems = (controller.isCash
                    //                     ? controller.itemsCash
                    //                     : controller.itemsCredit)
                    //                 .map((item) {
                    //               return InvoiceItem(
                    //                 itemName: item.itemName ?? "",
                    //                 unit: item.unit ?? "PC",
                    //                 quantity: int.tryParse(item.quantity ?? "0") ?? 0,
                    //                 amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
                    //                     (double.tryParse(item.mrp ?? "0") ?? 0.0),
                    //                 discount: double.tryParse(
                    //                         controller.discountController.text) ??
                    //                     0.0,
                    //                 itemDiscountAmount: _toInt(item.discountAmount),
                    //                 itemDiscountPercentace:
                    //                     _toInt(item.discountPercentance),
                    //                 itemVatTaxAmount: _toInt(item.vatAmount),
                    //                 itemvatTaxPercentace: _toInt(item.vatPerentace),
                    //                 customerName: _toInt(item.vatPerentace),
                    //               );
                    //             }).toList();

                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => NewInvoicePage(
                    //                   items: invoiceItems,
                    //                   billNo: widget.billNo,
                    //                   customerName: finalCustomerName,
                    //                   billPersion: billPersion,
                    //                   discountAmount: discountAmount,
                    //                   discountPercent: discountPercent,
                    //                   taxAmount: taxAmount,
                    //                   taxIdPercent: selectedTaxIdPercent,
                    //                 ),
                    //               ),
                    //             );
                    //           }
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text(
                    "View PDF",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                ),
    

             
      
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
      
                if (billNo.trim().isEmpty) {
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
      
      
                
                  
                  if (billNo.trim().isEmpty) {
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
                        billNo: billNo,
                        total: total);
      
                    if (isSuccess.isNotEmpty) {

                      final salesProvider = Provider.of<SalesReturnProvider>(context, listen: false);
                      salesProvider.fetchSalesReturn();

                      Navigator.pop(context);

                        controller.resetAll(); 
  

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                          content: Text(isSuccess),
                        ),
                      );

                    
                    
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
    );
  }
}
