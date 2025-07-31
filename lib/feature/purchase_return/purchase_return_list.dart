import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/purchase_return/presentation/purchase_return_view.dart';
import 'package:cbook_dt/feature/purchase_return/provider/purchase_return_provider.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_details.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseReturnList extends StatefulWidget {
  const PurchaseReturnList({super.key});

  @override
  State<PurchaseReturnList> createState() => _PurchaseReturnListState();
}

class _PurchaseReturnListState extends State<PurchaseReturnList> {
  @override
  void initState() {
    Future.microtask(() {
      Provider.of<PurchaseReturnProvider>(context, listen: false)
          .fetchPurchaseReturns();
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

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        title: const Text(
          "Purchase Return List",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        backgroundColor: colorScheme.primary,
        leading: const BackButton(color: Colors.white),
        //centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PurchaseReturnView(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    'P. Return',
                    style: TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [

            Consumer<PurchaseReturnProvider>(
  builder: (context, provider, child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        'Total Purchase Return: ৳${provider.totalReturn.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  },
),


            Expanded(
              child: Consumer<PurchaseReturnProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                        child: Text(provider.errorMessage,
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (provider.purchaseReturns.isEmpty) {
                    return const Center(
                        child: Text(
                      "No purchase returns found.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ));
                  }

                  return ListView.builder(
                    itemCount: provider.purchaseReturns.length,
                    itemBuilder: (context, index) {
                      final item = provider.purchaseReturns[index];

                      final returnPurchaseID =
                          provider.purchaseReturns[index].id;

                      return InkWell(
                        onLongPress: () {
                          editDeleteDiolog(
                              context, returnPurchaseID.toString());
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PurchaseReturnDetails(purchaseReturn: item),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color(0xfff4f6ff),
                          margin: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Supplier and Amount
                                SizedBox(
                                  width: 90,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.purchaseDate,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                      Text(
                                        item.billNumber ?? 'N/A',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),

                                //divider
                                Container(
                                  height: 45,
                                  width: 2,
                                  color: Colors.green.shade200,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                ),

                                // Right: cash and amount
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.supplierName == 'N/A'
                                          ? "Cash"
                                          : item.supplierName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "৳ ${item.grossTotal ?? 0}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),

                                Spacer(),

                                //unpaid
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        //color: Colors.yellow.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 6),
                                      child: const Text(
                                        'Unpaid',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.amber),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Future<dynamic> editDeleteDiolog(
      BuildContext context, String returnPurchaseID) {
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => PurchaseUpdateScreen(
                    //         purchaseId: int.parse(purchaseId)),
                    //   ),
                    // );
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
                    _showDeleteDialog(context, returnPurchaseID);
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
  void _showDeleteDialog(BuildContext context, String returnPurchaseID) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider =
        Provider.of<PurchaseReturnProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Purchase Return',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Purchase Return?',
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
              // Close confirmation dialog
              await provider.deletePurchaseReturn(returnPurchaseID, context);

              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
