import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/purchase/provider/purchase_provider.dart';
import 'package:cbook_dt/feature/purchase/purchase_details_page.dart';
import 'package:cbook_dt/feature/purchase/purchase_update.dart';
import 'package:cbook_dt/feature/purchase/purchase_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PurchaseListApi extends StatefulWidget {
  const PurchaseListApi({super.key});

  @override
  State<PurchaseListApi> createState() => _PurchaseListApiState();
}

class _PurchaseListApiState extends State<PurchaseListApi> {
  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime selectedEndDate = DateTime.now();

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  TextEditingController _searchController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is initialized
    Future.delayed(Duration.zero, () {
      Provider.of<PurchaseProvider>(context, listen: false).fetchPurchases();

      final purchaseProvider =
          Provider.of<PurchaseProvider>(context, listen: false);
      purchaseProvider.fetchItems();

      _searchController.addListener(() {
        Provider.of<PurchaseProvider>(context, listen: false)
            .filterPurchases(_searchController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      ///search, in app bar,
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        title: isSearching
            ? Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 35,
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      cursorHeight: 15,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: ' ',
                        hintStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        Provider.of<PurchaseProvider>(context, listen: false)
                            .filterPurchases(value);
                        // Your filter logic
                      },
                    ),
                  ),
                ],
              )
            : const Text(
                'Purchase List',
                style: TextStyle(color: Colors.yellow, fontSize: 16),
              ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: colorScheme.primary,
        actions: [
          // Search or Close Icon with circular background
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                  }
                });
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: isSearching ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                  border: isSearching
                      ? null
                      : Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) {
                        searchController.clear();
                        Provider.of<PurchaseProvider>(context, listen: false)
                            .filterPurchases(searchController.text);
                      }
                    });
                  },
                  child: Icon(
                    isSearching ? Icons.close : Icons.search,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),

          // Bill Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PurchaseView(),
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
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Purchase',
                    style: TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: Column(
          children: [
            ///amount, due, date, bill, qty
            Container(
              color: const Color(0xffdddefa),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ////date, current date, bill qty
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ///month start date
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: GestureDetector(
                                onTap: () => _selectDate(
                                    context, selectedStartDate, (date) {
                                  setState(() {
                                    selectedStartDate = date;
                                  });
                                }),
                                child: Container(
                                  height: 30,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
                                        style: GoogleFonts.notoSansPhagsPa(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                      const Icon(Icons.calendar_today,
                                          size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2 ),
                            Text("-",
                                style: GoogleFonts.notoSansPhagsPa(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 8),
                            // current date Picker
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: GestureDetector(
                                onTap: () => _selectDate(
                                    context, selectedEndDate, (date) {
                                  setState(() {
                                    selectedEndDate = date;
                                  });
                                }),
                                child: Container(
                                  height: 30 ,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
                                        style: GoogleFonts.notoSansPhagsPa(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                      const Icon(Icons.calendar_today,
                                          size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),

                        ///bill qty
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            "Bill Qty: 5",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    //amount, due
                    // const Column(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       "Amount: 12,50,36,589.00",
                    //       style: TextStyle(color: Colors.black, fontSize: 12),
                    //     ),
                    //     Text(
                    //       "Due: 10,85,99,782.00",
                    //       style: TextStyle(color: Colors.black, fontSize: 12),
                    //     )
                    //   ],
                    // )
                     
                     Consumer<PurchaseProvider>(
  builder: (context, provider, child) {
    final summary = provider.summary;

    if (summary == null) {
      return const SizedBox(); // or show loading text
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Purchase: ৳${summary.totalPurchase}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
        ),
        Text(
          "Total Payment: ৳${summary.totalPayment}",
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        Text(
          "Total Due: ৳${summary.totalDue}",
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  },
),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 1,
            ),

            const SizedBox(
              height: 1,
            ),

            Expanded(
              child: Consumer<PurchaseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.purchaseData == null ||
                      provider.purchaseData!.data == null ||
                      provider.purchaseData!.data!.isEmpty) {
                    return const Center(
                        child: Text('No Purchase data available',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 1),
                    itemCount: provider.purchaseData!.data!.length,
                    itemBuilder: (context, index) {
                      final purchase = provider.purchaseData!.data![index];
                      bool isEnabled = purchase.disabled == 'enable';

                      final purchaseId =
                          purchase.purchaseDetails!.first.purchaseId.toString();

                      //final transactionMethod = purchase.transectionMethod;

                      final transactionMethod =
                          purchase.transactionMethod ?? '';

                      debugPrint('transactionMethod ==>${transactionMethod}');

                      final paymentStatus = purchase.paymentStatus ?? 0;

                      return InkWell(
                        onLongPress: () {
                          editDeleteDiolog(context, purchaseId,
                              transactionMethod, paymentStatus);
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PurchaseDetailsPage(purchase: purchase),
                            ),
                          );
                        },
                        child: Card(
                          shadowColor: const Color.fromARGB(255, 12, 9, 199),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              6.0,
                            ),
                            // side: BorderSide(color: Color(0xffdddefa))
                          ),
                          elevation: 1,
                          margin: const EdgeInsets.all(2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Left side: Supplier info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          //date, invoice number
                                          SizedBox(
                                            width: 90,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  formatDate(
                                                      purchase.pruchaseDate),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                                Text('${purchase.billNumber}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),

                                          //divider
                                          Container(
                                            height: 30,
                                            width: 2,
                                            color: Colors.green.shade200,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                          ),

                                          //cash or customer name, amount
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (purchase.supplier == 'N/A')
                                                    ? 'Cash'
                                                    : purchase.supplier!,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                  '৳ ${purchase.grossTotal ?? 0}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                /// End Right side:, paid, unpaid, due amount, edit, delete
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //=>paid, unpaid, due amount , //=> edit  and update button
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              purchase.paymentStatus == 2
                                                  ? 'Paid'
                                                  : purchase.paymentStatus == 1
                                                      ? 'Partial'
                                                      : 'Unpaid',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: purchase.paymentStatus ==
                                                        2
                                                    ? Colors.green
                                                    : purchase.paymentStatus ==
                                                            1
                                                        ? Colors.orange
                                                        : Colors.red,
                                              ),
                                            ),
                                            purchase.transactionMethod!
                                                        .toLowerCase() ==
                                                    'customer'
                                                ? Text(
                                                    "Due: ${purchase.due} TK", // Show due amount here
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      // fontWeight:
                                                      //     FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                      ],
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

  /// Helper method to build formatted rows
  Widget _buildRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }

  Future<dynamic> editDeleteDiolog(
    BuildContext context,
    String purchaseId,
    String transactionMethod,
    int paymentStatus,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ Only disable if paymentStatus is 1 (partial)
    final disableActions = paymentStatus == 2;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Action',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // ✅ Edit Button
                InkWell(
                  onTap: disableActions
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseUpdateScreen(
                                purchaseId: int.parse(purchaseId),
                              ),
                            ),
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        color: disableActions ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
                ),

                // ✅ Delete Button
                InkWell(
                  onTap: disableActions
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _showDeleteDialog(context, purchaseId);
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 16,
                        color: disableActions ? Colors.grey : Colors.red,
                      ),
                    ),
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
  void _showDeleteDialog(BuildContext context, String purchaseId) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Purchase',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Purchase?',
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
              // Navigator.of(context).pop(); // Close dialog first

              final provider =
                  Provider.of<PurchaseProvider>(context, listen: false);

              // ✅ Call delete from Provider
              await provider.deletePurchase(int.parse(purchaseId));

              provider.fetchPurchases();

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Successfully!, Purchase voucher Deleted.")),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
