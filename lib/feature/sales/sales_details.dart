import 'dart:math';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/authentication/currency/provider/currency_controller.dart';
import 'package:cbook_dt/feature/sales/model/sales_list_model.dart';
import 'package:cbook_dt/feature/sales/provider/sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesDetails extends StatefulWidget {
  final SaleItem sale;
  const SalesDetails({super.key, required this.sale});

  @override
  State<SalesDetails> createState() => _SalesDetailsState();
}

class _SalesDetailsState extends State<SalesDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saleProvider = Provider.of<SalesProvider>(context, listen: false);
      saleProvider.fetchItems();
      saleProvider.fetchUnits();
      _loadSettings();
    });

    Future.microtask(() =>
        Provider.of<CurrencyProvider>(context, listen: false).fetchCurrency());
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

  bool _billWiseVatTax = false;
  bool _billWiseDiscount = false;
  bool _isLoading = true;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _billWiseVatTax = prefs.getBool('billWiseVatTax') ?? false;
        _billWiseDiscount = prefs.getBool('billWiseDiscount') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    double value = double.tryParse(number.toString()) ?? 0;
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = Provider.of<SalesProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          leading: const BackButton(color: Colors.white),
          title: const Text(
            "Sales Details",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Sales Details",
          style: const TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.green.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: customRowSales(
                            widget.sale.customerName != null &&
                                    widget.sale.customerName != "N/A"
                                ? widget.sale.customerName!
                                : "Cash",
                          ),
                        ),

                        // Safe customer phone display
                        if (widget.sale.transactionMethod == 'customer' &&
                            widget.sale.customerDetails != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: customRowSales(
                                widget.sale.customerDetails!.phone ??
                                    'No phone'),
                          ),

                        // Safe customer address display
                        if (widget.sale.transactionMethod == 'customer' &&
                            widget.sale.customerDetails != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: customRowSales(
                                widget.sale.customerDetails!.address ??
                                    'No address'),
                          ),

                        Consumer<CurrencyProvider>(
                            builder: (context, currencyProvider, child) {
                          final currency =
                              currencyProvider.currencyModel?.currency ?? '';
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: customRowSales(
                              "Bill Amount:  ${_formatNumber(widget.sale.grossTotal)} $currency",
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Right side
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            formatDate(widget.sale.purchaseDate?.toString()),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            widget.sale.billNumber ?? 'N/A',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        if (widget.sale.purchaseDetails.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              widget.sale.purchaseDetails.first.type ?? 'N/A',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            // const Text('Sales Details:',
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black)),
            Expanded(
              child: widget.sale.purchaseDetails.isEmpty
                  ? const Center(
                      child: Text(
                        'No purchase details available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.sale.purchaseDetails.length,
                      itemBuilder: (context, index) {
                        final detail = widget.sale.purchaseDetails[index];

                        // Safe item name retrieval
                        String itemName = 'Unknown Item';
                        try {
                          itemName = saleProvider.getItemName(detail.itemId!) ??
                              'Unknown Item';
                        } catch (e) {
                          print('Error getting item name: $e');
                        }

                        // Safe unit symbol retrieval
                        String unitSymbol = '';
                        try {
                          unitSymbol =
                              saleProvider.getUnitSymbol(detail.unitId!) ?? '';
                        } catch (e) {
                          print('Error getting unit symbol: $e');
                        }

                        return Card(
                          margin: const EdgeInsets.only(left: 4, bottom: 2),
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              itemName,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // RichText(
                                //   text: TextSpan(
                                //     style: const TextStyle(
                                //         color: Colors.black, fontSize: 12),
                                //     children: [

                                //       TextSpan(
                                //           text:
                                //               '${_formatNumber(detail.qty)} $unitSymbol x ৳ ${_formatNumber(detail.price)}'
                                //               '${(_billWiseDiscount && (double.tryParse(detail.discountPercentage?.toString() ?? "0") != 0 || double.tryParse(detail.discountAmount?.toString() ?? "0") != 0)) ? ' (-) Disc: ${_formatNumber(detail.discountPercentage)}% (${_formatNumber(detail.discountAmount)}),' : ''}'
                                //               '${(_billWiseDiscount && (double.tryParse(detail.taxPercentage?.toString() ?? "0") != 0 || double.tryParse(detail.taxAmount?.toString() ?? "0") != 0)) ? ' (+) Tax: ${_formatNumber(detail.taxPercentage)}% (${_formatNumber(detail.taxAmount)})' : ''} = ',
                                //           style: const TextStyle(fontSize: 14)),

                                //       TextSpan(
                                //         text:
                                //             '${_formatNumber(detail.subTotal)}',
                                //         style: const TextStyle(
                                //             color: Colors.purple,
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 14),
                                //       ),
                                //     ],
                                //   ),
                                //   overflow: TextOverflow.ellipsis,
                                // ),

                                Consumer<CurrencyProvider>(builder:
                                    (context, currencyProvider, child) {
                                  final currency = currencyProvider
                                          .currencyModel?.currency ??
                                      '৳';

                                  return RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 12),
                                      children: [
                                        TextSpan(
                                            text:
                                                '${_formatNumber(detail.qty)} $unitSymbol x  ${_formatNumber(detail.price)} $currency'
                                                '${(_billWiseDiscount && (double.tryParse(detail.discountPercentage?.toString() ?? "0") != 0 || double.tryParse(detail.discountAmount?.toString() ?? "0") != 0)) ? ' (-) Disc: ${_formatNumber(detail.discountPercentage)}% ($currency${_formatNumber(detail.discountAmount)}),' : ''}'
                                                '${(_billWiseDiscount && (double.tryParse(detail.taxPercentage?.toString() ?? "0") != 0 || double.tryParse(detail.taxAmount?.toString() ?? "0") != 0)) ? ' (+) Tax: ${_formatNumber(detail.taxPercentage)}% ($currency${_formatNumber(detail.taxAmount)})' : ''} = ',
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        TextSpan(
                                          text:
                                              '${_formatNumber(detail.subTotal)} $currency',
                                          style: const TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }),
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

  Widget customRowSales(dynamic text2, {bool? isBlod}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              text2?.toString() ?? 'N/A',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight:
                      isBlod == true ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
