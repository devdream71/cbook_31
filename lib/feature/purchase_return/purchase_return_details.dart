import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/purchase_return/model/purchase_return_list_model.dart';
import 'package:cbook_dt/feature/purchase_return/provider/purchase_return_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseReturnDetails extends StatelessWidget {
  final PurchaseReturn purchaseReturn;

  const PurchaseReturnDetails({super.key, required this.purchaseReturn});

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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint(purchaseReturn.toString());

    // Ensure the PurchaseReturnProvider is available in the context
    final provider = Provider.of<PurchaseReturnProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Purchase Return Details: ${purchaseReturn.billNumber}",
            style: const TextStyle(fontSize: 13, color: Colors.yellow),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Supplier: ${purchaseReturn.supplierName}",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text(
              "Total: ৳ ${purchaseReturn.grossTotal},",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            Text(
              "Date: ${formatDate(purchaseReturn.purchaseDate)}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            Text(
              "Status: ${purchaseReturn.disabled}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Purchase Details:",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Expanded(
              child: ListView.builder(
                itemCount: purchaseReturn.purchaseDetails.length,
                itemBuilder: (context, index) {
                  final detail = purchaseReturn.purchaseDetails[index];
                  return Card(
                    child: ListTile(
                      title:
                          // Text(
                          //   "Item ID: ${detail.itemId}",
                          //   style: const TextStyle(
                          //     fontSize: 13,
                          //   ),
                          // ),
                          Text(
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
                            "Price: ৳ ${detail.price}",
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Subtotal: ৳ ${detail.subTotal}",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
