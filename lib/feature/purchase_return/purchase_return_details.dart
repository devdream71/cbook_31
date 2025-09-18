 import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/authentication/currency/provider/currency_controller.dart';
import 'package:cbook_dt/feature/purchase_return/model/purchase_return_list_model.dart';
import 'package:cbook_dt/feature/purchase_return/provider/purchase_return_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseReturnDetails extends StatefulWidget {
  final PurchaseReturn purchaseReturn;

  const PurchaseReturnDetails({super.key, required this.purchaseReturn});

  @override
  State<PurchaseReturnDetails> createState() => _PurchaseReturnDetailsState();
}

class _PurchaseReturnDetailsState extends State<PurchaseReturnDetails> {
  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<CurrencyProvider>(context, listen: false).fetchCurrency());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint(widget.purchaseReturn.toString());

    // Ensure the PurchaseReturnProvider is available in the context
    final provider = Provider.of<PurchaseReturnProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Purchase Return Details: ${widget.purchaseReturn.billNumber}",
            style: const TextStyle(fontSize: 13, color: Colors.yellow),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Supplier: ${widget.purchaseReturn.supplierName}",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            
            // ✅ Updated: Use dynamic currency for total
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                final currency = currencyProvider.currencyModel?.currency ?? '৳';
                return Text(
                  "Total:  ${widget.purchaseReturn.grossTotal} $currency",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                );
              }
            ),
            
            Text(
              "Date: ${formatDate(widget.purchaseReturn.purchaseDate)}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            // Text(
            //   "Status: ${widget.purchaseReturn.disabled}",
            //   style: const TextStyle(
            //     color: Colors.black,
            //     fontSize: 13,
            //   ),
            // ),
            const SizedBox(height: 10),
            const Text("Purchase Details:",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            
            // ✅ Updated: Use dynamic currency in purchase details list
            Expanded(
              child: Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  final currency = currencyProvider.currencyModel?.currency ?? '৳';
                  
                  return ListView.builder(
                    itemCount: widget.purchaseReturn.purchaseDetails.length,
                    itemBuilder: (context, index) {
                      final detail = widget.purchaseReturn.purchaseDetails[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            "Item: ${provider.getItemName(detail.itemId)}", // Updated to show item name
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quantity: ${detail.qty}",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Price:  ${detail.price} $currency",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Subtotal:  ${detail.subTotal} $currency",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Purchase Date: ${detail.purchaseDate}",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
