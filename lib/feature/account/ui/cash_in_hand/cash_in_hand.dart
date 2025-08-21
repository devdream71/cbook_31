import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/account/ui/account_type/account_type_create.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/adjust_cash_create.dart';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/provider/cash_in_hand.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CashInHand extends StatefulWidget {
  CashInHand({super.key});

  @override
  State<CashInHand> createState() => _CashInHandState();
}

class _CashInHandState extends State<CashInHand> {
  @override
  void initState() {
    super.initState();
    Provider.of<CashInHandProvider>(context, listen: false)
        .fetchCashInHandData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
 

    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          //centerTitle: true,
          title: const Text(
            'Cash in hand',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: ()   {
                   Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdjustCashCreate()));
                  },
                  child: const Text(
                    'Adjust Cash',
                    style: TextStyle(color: Colors.yellow, fontSize: 15),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccountTypeCreate()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                         

                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.add),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<CashInHandProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final dataList = provider.cashInHandModel?.data ?? [];

            if (dataList.isEmpty) {
              return const Center(
                  child: Text(
                "No Data Found",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    "Total Amount: ৳ ${provider.amountSum.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      //fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final item = dataList[index];
                      final cashID = dataList[index].id;
                      return InkWell(
                        onLongPress: () {
                          editDeleteDiolog(context, cashID!);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Sales Number and Date
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      
                                      item.billNumber == '' ? Text(
                                        item.billType ?? '',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ) : 
                                      
                                      Text(
                                        item.billNumber ?? '',
                                        style: GoogleFonts.lato(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 4),
                                      Text(
                                        item.date ?? '',
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Middle Column: Bill Type and Account
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.billType ?? '',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.account ?? '',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Right side: Amount
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      "৳ ${item.amount ?? ''}",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ));
  }

  ///edit and delete pop up.
  Future<dynamic> editDeleteDiolog(BuildContext context, int cashID) {
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
                // const SizedBox(height: 16),
                // InkWell(
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     //Navigate to Edit Page
                //     // Navigator.push(
                //     //   context,
                //     //   MaterialPageRoute(
                //     //     builder: (context) =>
                //     //         TaxEdit(taxId: cashID),
                //     //   ),
                //     // );
                //   },
                //   child: const Padding(
                //     padding: EdgeInsets.symmetric(vertical: 12),
                //     child: Text('Edit',
                //         style: TextStyle(fontSize: 16, color: Colors.blue)),
                //   ),
                // ),
                // const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, cashID);
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

  ///delete bill person.
  void _showDeleteDialog(BuildContext context, int cashID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Cash in Hand',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Cash In Hand?',
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
              //Navigator.of(context).pop(); // Close dialog

              final provider =
                  Provider.of<CashInHandProvider>(context, listen: false);

              bool success = await provider.deleteCashInHand(cashID);

              if (success) {
                // ✅ Re-fetch the latest list

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Successfully, Cash In Hand deleted.'),
                  ),
                );

                await provider.fetchCashInHandData();

                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Failed to delete Cash In Hand.'),
                  ),
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


