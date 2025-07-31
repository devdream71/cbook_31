import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales_return/model/sale_return_model.dart';
import 'package:cbook_dt/feature/sales_return/provider/sale_return_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesReturnDetailsPage extends StatelessWidget {
  final SalesReturnData salesReturn;

  const SalesReturnDetailsPage({super.key, required this.salesReturn});

  ///formate date.
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
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          leading: const BackButton(color: Colors.white),
          title: Text("Sales Details: ${salesReturn.billNumber}",
              style: const TextStyle(color: Colors.yellow, fontSize: 16))),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              salesReturn.supplierName.trim().toLowerCase() == 'n/a'
                  ? 'Cash'
                  : salesReturn.supplierName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            Text(
              "Date: ${formatDate(salesReturn.purchaseDate)} ,",
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),

             
            Text("Total: ৳ ${salesReturn.grossTotal}",
                style: const TextStyle(fontSize: 12, color: Colors.black)),
            const SizedBox(height: 10),
            const Text("Purchase Details",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const Divider(),
            Expanded(
              child: Consumer<SalesReturnProvider>(
                builder: (context, provider, _) {
                  return ListView.builder(
                    itemCount: salesReturn.purchaseDetails.length,
                    itemBuilder: (context, index) {
                      final detail = salesReturn.purchaseDetails[index];
                      final itemName = provider.getItemName(detail.itemId);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            "Item: $itemName",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Quantity: ${detail.qty}",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12)),
                              Text("Price: ৳ ${detail.price}",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12)),
                              Text("Subtotal: ৳ ${detail.subTotal}",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
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
