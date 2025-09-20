import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/authentication/currency/provider/currency_controller.dart';
import 'package:cbook_dt/feature/sales_return/model/sale_return_model.dart';
import 'package:cbook_dt/feature/sales_return/provider/sale_return_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesReturnDetailsPage extends StatefulWidget {
  final SalesReturnData salesReturn;

  const SalesReturnDetailsPage({super.key, required this.salesReturn});

  @override
  State<SalesReturnDetailsPage> createState() => _SalesReturnDetailsPageState();
}

class _SalesReturnDetailsPageState extends State<SalesReturnDetailsPage> {
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
  void initState() {
    super.initState();
    // Fetch the data when the screen is initialized
    Future.microtask(() =>
        Provider.of<CurrencyProvider>(context, listen: false).fetchCurrency());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          leading: const BackButton(color: Colors.white),
          title: Text("Sales Returns Details: ${widget.salesReturn.billNumber}",
              style: const TextStyle(color: Colors.yellow, fontSize: 16))),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.salesReturn.supplierName.trim().toLowerCase() == 'n/a'
                  ? 'Cash'
                  : widget.salesReturn.supplierName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            Text(
              "Date: ${formatDate(widget.salesReturn.purchaseDate)} ,",
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),

            // ✅ Updated: Use dynamic currency for total
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                final currency = currencyProvider.currencyModel?.currency ?? '';
                return Text(
                  "Total:  ${widget.salesReturn.grossTotal} $currency",
                  style: const TextStyle(fontSize: 12, color: Colors.black)
                );
              }
            ),
            
            const SizedBox(height: 10),
            const Text("Purchase Details",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const Divider(),
            
            // ✅ Updated: Use dynamic currency in purchase details list
            Expanded(
              child: Consumer2<SalesReturnProvider, CurrencyProvider>(
                builder: (context, salesReturnProvider, currencyProvider, _) {
                  final currency = currencyProvider.currencyModel?.currency ?? '৳';
                  
                  return ListView.builder(
                    itemCount: widget.salesReturn.purchaseDetails.length,
                    itemBuilder: (context, index) {
                      final detail = widget.salesReturn.purchaseDetails[index];
                      final itemName = salesReturnProvider.getItemName(detail.itemId);

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
                              Text("Price:  ${detail.price} $currency",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12)),
                              Text("Subtotal:  ${detail.subTotal} $currency",
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

            const SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }
}
 