import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/Received/create_recevied_item.dart';
import 'package:cbook_dt/feature/Received/provider/received_provider.dart';
import 'package:cbook_dt/feature/Received/recevied_details.dart';
import 'package:cbook_dt/feature/Received/recevied_edit.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ReceivedList extends StatefulWidget {
  const ReceivedList({super.key});

  @override
  State<ReceivedList> createState() => _ReceivedListState();
}

class _ReceivedListState extends State<ReceivedList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ReceiveVoucherProvider>(context, listen: false)
            .fetchReceiveVouchers());
  }

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);
  TextStyle ts2 = const TextStyle(
      color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

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
                'Received',
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
                        builder: (context) => const ReceivedCreateItem()));
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///top date start , end and dropdown

              Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),


                  Consumer<ReceiveVoucherProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return const Center(child: Text(''));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        'Total Received: ৳${provider.totalReceived.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  },
),


                  Consumer<ReceiveVoucherProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.vouchers.isEmpty) {
                        return const Center(
                            child: Text(
                          'No Receive Vouchers Found',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            provider.vouchers.length, // ✅ Show all vouchers
                        itemBuilder: (context, index) {
                          final voucher = provider.vouchers[index];

                          final voucherId = voucher.id.toString();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 0),
                            child: InkWell(
                              onLongPress: () async {
                                editDeleteDiolog(context, voucherId);
                              },
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ReceviedDetails()));
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
                                      // Left Side
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Right Side
                                                SizedBox(
                                                  width: 80,
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              voucher
                                                                  .voucherDate,
                                                              style:
                                                                  ts), // Date
                                                          Text(
                                                              voucher
                                                                  .voucherNumber,
                                                              style:
                                                                  ts), // Voucher Number
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                              voucher
                                                                  .totalAmount
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style:
                                                                  ts2), // Amount
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(width: 5),

                                                //Divider (vertical)
                                                Container(
                                                  height: 55,
                                                  width: 2,
                                                  color: Colors.green.shade200,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                ),

                                                const SizedBox(width: 5),

                                                // Received To
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Received To',
                                                          style: ts2),
                                                      Text('Cash In Hand',
                                                          style:
                                                              ts), // Static Text
                                                      Text('Cash',
                                                          style:
                                                              ts), // Static Text
                                                    ],
                                                  ),
                                                ),

                                                // Received From
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text('Received From',
                                                          style: ts2),
                                                      Text(voucher.customer,
                                                          style:
                                                              ts), // Customer Name
                                                      Text('N/A',
                                                          style:
                                                              ts), // Static Phone (if available, replace with real data)
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
                        },
                      );
                    },
                  ),
                ],
              ),

              ///Bottom
            ],
          ),
        ));
  }

  ///show edit and delete list from alart diolog
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border.all(
                              color: Colors.grey,
                              width: 1), // Border color and width
                          borderRadius: BorderRadius.circular(
                              50), // Corner radius, adjust as needed
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary, // Use your color
                          ),
                        ),
                      ),
                    )
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
                            ReceviedEdit(receviedId: voucherId),
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

  ////delete recived item from list
  void _showDeleteDialog(BuildContext context, String voucherId) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Receipt in',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Receipt in?',
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
                  Provider.of<ReceiveVoucherProvider>(context, listen: false);
              bool isDeleted = await provider.deleteRecivedVoucher(voucherId);

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                    'Received voucher deleted successfully!',
                    style: TextStyle(color: colorScheme.primary),
                  )),
                );
                Navigator.of(context).pop(); // Close confirmation dialog
                await provider.fetchReceiveVouchers();
              } else {
                Navigator.of(context).pop(); // Close confirmation dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                    'Failed to delete Received voucher.',
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
}
