import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/purchase/provider/purchase_provider.dart';
import 'package:cbook_dt/feature/transaction/model/purchase_tr_list_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseDetailsPage extends StatefulWidget {
  final Data purchase;

  const PurchaseDetailsPage({super.key, required this.purchase});

  @override
  State<PurchaseDetailsPage> createState() => _PurchaseDetailsPageState();
}

class _PurchaseDetailsPageState extends State<PurchaseDetailsPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<PurchaseProvider>(context, listen: false).fetchItems();
      final purchaseProvider =
          Provider.of<PurchaseProvider>(context, listen: false);
      purchaseProvider.fetchItems();
      purchaseProvider.fetchUnits();
    });
    super.initState();
  }

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
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Purchase Details - ${widget.purchase.billNumber}",
          style: const TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // customRowPurchase(
            //     "Customer Name:", widget.purchase.supplier ?? 'N/A',
            //     isBlod: true),
            //==>if purchase supplier name have then show supplier name other wise show cash. <<<<======
            customRowPurchase(
                "Customer Name:",
                widget.purchase.supplier != 'N/A'
                    ? widget.purchase.supplier
                    : "Cash",
                isBlod: true),
            customRowPurchase(
              "Bill Number:",
              widget.purchase.billNumber,
            ),
            //customRowPurchase("Purchase Date:", widget.purchase.pruchaseDate),
            customRowPurchase(
                "Purchase Date:", formatDate(widget.purchase.pruchaseDate)),
            customRowPurchase(
                "Details Notes", widget.purchase.detailsNotes ?? "N/A"),
            customRowPurchase(
                "Discount:", "৳ ${(widget.purchase.discount ?? 0).toString()}"),
            customRowPurchase("Total Amount:",
                "৳ ${(widget.purchase.grossTotal ?? 0).toString()}"),
            const SizedBox(height: 10),

            const Text("Purchase Details:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.purchase.purchaseDetails?.length ?? 0,
                itemBuilder: (context, index) {
                  final details = widget.purchase.purchaseDetails![index];

                  // Get item name from the provider
                  String itemName =
                      purchaseProvider.getItemName(details.itemId!);

                  String unitSymbol =
                      purchaseProvider.getUnitSymbol(details.unitId!);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        "Item: $itemName - $unitSymbol",
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "Quantity: ${details.qty}, Price: ৳${details.price}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        "Subtotal: ৳ ${details.subTotal}",
                        style:
                            const TextStyle(color: Colors.green, fontSize: 12),
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

  Widget customRowPurchase(String text1, dynamic text2, {bool? isBlod}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1,
          style: TextStyle(
              color: Colors.black,
              fontWeight: isBlod == true ? FontWeight.bold : FontWeight.normal,
              fontSize: 12),
        ),
        Text(text2,
            style: TextStyle(
                color: Colors.black,
                fontWeight:
                    isBlod == true ? FontWeight.bold : FontWeight.normal,
                fontSize: 12)),
      ],
    );
  }
}
