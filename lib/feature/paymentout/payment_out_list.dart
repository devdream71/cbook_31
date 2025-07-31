import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/paymentout/create_payment_out_item.dart';
import 'package:cbook_dt/feature/paymentout/payment_details.dart';
import 'package:cbook_dt/feature/paymentout/payment_out_edit.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class PaymentOutList extends StatefulWidget {
  const PaymentOutList({super.key});

  @override
  State<PaymentOutList> createState() => _PaymentOutListState();
}

class _PaymentOutListState extends State<PaymentOutList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchPaymentVouchers());
  }

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);
  TextStyle ts2 = const TextStyle(
      color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Default to current date
    String? selectedDropdownValue;

    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: const Column(
            children: [
              SizedBox(
                width: 5,
              ),
              Text(
                'Payment out',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5,
              )
            ],
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentOutCreateItem()));
              },
              child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.yellow,
                  child: Icon(
                    Icons.add,
                    color: colorScheme.primary,
                  )),
            ),
          ],
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [

                  Consumer<PaymentVoucherProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            'Total Payment: ৳${provider.totalPayment.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        provider.vouchers.isEmpty
            ? const Text('No Payment Vouchers Found.', style: TextStyle(color: Colors.black),)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.vouchers.length,
                itemBuilder: (context, index) {
                  final voucher = provider.vouchers[index];
                  // existing card UI
                },
              )
      ],
    );
  },
),


                   
                  Consumer<PaymentVoucherProvider>(
                      builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.vouchers.isEmpty) {
                      return Center(
                          child: Text(
                        'No Payment Vouchers Found.',
                        style: ts2,
                      ));
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = provider.vouchers[index];

                          final voucherId = voucher.id.toString();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 0),
                            child: InkWell(
                              onLongPress: () {
                                editDeleteDiolog(context, voucherId);
                              },
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             const PaymentDetails()));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0)),
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 2),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 6.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          ///voucher date.
                                                          Text(
                                                              voucher
                                                                  .voucherDate,
                                                              style: ts),

                                                          ///voucher number
                                                          Text(
                                                            voucher.voucherNumber
                                                                        .length >
                                                                    12
                                                                ? "${voucher.voucherNumber.substring(0, 10)}..."
                                                                : voucher
                                                                    .voucherNumber,
                                                            style: ts,
                                                          ),

                                                          const SizedBox(
                                                              height: 5),

                                                          ///voucher amount.
                                                          Text(
                                                              voucher
                                                                  .totalAmount
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: ts2),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Container(
                                                  height: 55,
                                                  width: 2,
                                                  color: Colors.green.shade200,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Payment From',
                                                          style: ts2),
                                                      Text('Cash In Hand',
                                                          style: ts),
                                                      Text('Cash', style: ts),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text('Payment To',
                                                          style: ts2),
                                                      Text(voucher.customer,
                                                          style: ts),
                                                      Text('N/A',
                                                          style:
                                                              ts), // Add phone if available
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  }),
                ],
              ),
            ),
          ],
        ));
  }

  Future<dynamic> editDeleteDiolog(BuildContext context, String voucherId) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16), // Adjust side padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Height as per content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Action',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    closeButtonIcon(context, colorScheme)
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    //Navigate to Edit Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymenyOutEdit(paymentOutId: voucherId),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                // const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, voucherId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete',
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String voucherId) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete payment Vouchers',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this payemnt Vouchers?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider =
                  Provider.of<PaymentVoucherProvider>(context, listen: false);
              bool isDeleted = await provider.deletePaymentVoucher(voucherId);

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'Successfully! Payment voucher deleted.',
                        style: TextStyle(color: colorScheme.primary),
                      )),
                );
                Navigator.of(context).pop(); // Close confirmation dialog
                await provider.fetchPaymentVouchers();
              } else {
                Navigator.of(context).pop(); // Close confirmation dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                    'Failed to delete payment voucher.',
                    style: TextStyle(color: Colors.red),
                  )),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  InkWell closeButtonIcon(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          border: Border.all(
              color: Colors.grey, width: 1), // Border color and width
          borderRadius:
              BorderRadius.circular(50), // Corner radius, adjust as needed
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: 20,
            color: colorScheme.primary, // Use your color
          ),
        ),
      ),
    );
  }
}
