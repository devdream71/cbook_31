import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales/model/sales_list_model.dart';
import 'package:cbook_dt/feature/sales/provider/sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesDetails extends StatefulWidget {
  final SaleItem sale;
  const SalesDetails({super.key, required this.sale});

  @override
  State<SalesDetails> createState() => _SalesDetailsState();
}

class _SalesDetailsState extends State<SalesDetails> {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<SalesProvider>(context, listen: false).fetchItems();
      final saleProvider = Provider.of<SalesProvider>(context, listen: false);
      saleProvider.fetchItems();
      saleProvider.fetchUnits();
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
    final saleProvider = Provider.of<SalesProvider>(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Sales Details - ${widget.sale.billNumber}",
          style: const TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // customRowSales("Customer Name:", widget.sale.customerName, isBlod: true),
            customRowSales(
              "Customer Name:",
              widget.sale.customerName != "N/A"
                  ? widget.sale.customerName
                  : "Cash",
            ),
            customRowSales(
              "Transaction Method:",
              widget.sale.transactionMethod,
            ),

            customRowSales(
              "Purchase Date:",
              //widget.sale.purchaseDate.toString(),
              formatDate(widget.sale.purchaseDate.toString()),
            ),

            customRowSales(
              "Discount:",
              "৳ ${widget.sale.discount.toString()}",
            ),
            customRowSales(
              "Gross Total:",
              "৳ ${widget.sale.grossTotal.toString()}",
            ),
            const SizedBox(height: 10),
            const Text('Sales Details:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.sale.purchaseDetails.length,
                itemBuilder: (context, index) {
                  final detail = widget.sale.purchaseDetails[index];
                  // Get item name from the provider
                  String itemName = saleProvider.getItemName(detail.itemId!);
                  // Get item name and unit symbol
                  //String itemName = saleProvider.getItemName(detail.itemId!);
                  String unitSymbol =
                      saleProvider.getUnitSymbol(detail.unitId!);
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Item : $itemName - $unitSymbol',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity: ${detail.qty}, Price: ৳ ${detail.price.toString()}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                          Text(
                            'Discount: ${detail.discountAmount} ৳,  ${detail.discountPercentage} %',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                          Text(
                            'Tax: ${detail.taxAmount} ৳,   ${detail.taxPercentage} %',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Text(
                        'Subtotal: ৳ ${detail.subTotal.toString()}',
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

  Widget customRowSales(String text1, dynamic text2, {bool? isBlod}) {
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
