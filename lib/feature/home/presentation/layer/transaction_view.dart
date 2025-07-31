import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/purchase/provider/purchase_provider.dart';
import 'package:cbook_dt/feature/transaction/ui/transection_new.dart';
// import 'package:cbook_dt/feature/transaction/provider/purchase_tr_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class TransactionView extends StatefulWidget {
  const TransactionView({super.key});

  @override
  TransactionViewState createState() => TransactionViewState();
}

class TransactionViewState extends State<TransactionView> {
  DateTime selectedStartDate = DateTime.now(); // Default to current date
  DateTime selectedEndDate = DateTime.now(); // Default to current date
  String? selectedDropdownValue;

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

  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is initialized
    Future.delayed(Duration.zero, () {
      Provider.of<PurchaseProvider>(context, listen: false).fetchPurchases();
    });
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

  Future<void> _deletePurchase(int purchaseId) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/purchase/remove?id=$purchaseId');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Purchase deleted successfully")),
          );

          // Remove from UI by updating the provider
          // Provider.of<PurchaseProvider>(context, listen: false)
          //     .removePurchase(purchaseId); // This will update the UI
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete purchase")),
          );
        }
      } else {
        throw Exception('Failed to delete purchase');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting purchase: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.primary,
          title: const Text(
            "Transaction",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // First Child: Row with Icons and Text

          ///===>>>transction, stock, custopmer, supplier
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       // Reuse the existing decoration for buttons
          //       //transction
          //       InkWell(
          //         onTap: () {
          //           showDialog(
          //               context: context,
          //               builder: (context) =>
          //                   const FeatureNotAvailableDialog());
          //         },
          //         child: DecoratedBox(
          //           decoration: BoxDecoration(
          //             color: const Color(0xffe3e7fa),
          //             borderRadius: BorderRadius.circular(25),
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 8.0, vertical: 4),
          //             child: Row(
          //               children: [
          //                 const Icon(Icons.swap_horiz, size: 20),
          //                 const SizedBox(width: 4),
          //                 Text(
          //                   "Transaction",
          //                   style: GoogleFonts.notoSansPhagsPa(
          //                       color: Colors.black, fontSize: 12),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),

          //       const SizedBox(
          //         width: 5,
          //       ),

          //       //stock
          //       InkWell(
          //         onTap: () {
          //           showDialog(
          //               context: context,
          //               builder: (context) =>
          //                   const FeatureNotAvailableDialog());
          //         },
          //         child: DecoratedBox(
          //           decoration: BoxDecoration(
          //             color: const Color(0xffe3e7fa),
          //             borderRadius: BorderRadius.circular(25),
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 8.0, vertical: 4),
          //             child: Row(
          //               children: [
          //                 const Icon(Icons.storage, size: 20),
          //                 const SizedBox(width: 4),
          //                 Text(
          //                   "Stock",
          //                   style: GoogleFonts.notoSansPhagsPa(
          //                       color: Colors.black, fontSize: 12),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 5,
          //       ),

          //       //customer
          //       InkWell(
          //         onTap: () {
          //           Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => CustomerListScreen()));
          //         },
          //         child: DecoratedBox(
          //           decoration: BoxDecoration(
          //             color: const Color(0xffe3e7fa),
          //             borderRadius: BorderRadius.circular(25),
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 8.0, vertical: 4),
          //             child: Row(
          //               children: [
          //                 const Icon(Icons.group, size: 20),
          //                 const SizedBox(width: 4),
          //                 Text(
          //                   "Customers",
          //                   style: GoogleFonts.notoSansPhagsPa(
          //                       color: Colors.black, fontSize: 12),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 5,
          //       ),

          //       //supplier
          //       InkWell(
          //         onTap: () {
          //           Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => SupplierListScreen()));
          //         },
          //         child: DecoratedBox(
          //           decoration: BoxDecoration(
          //             color: const Color(0xffe3e7fa),
          //             borderRadius: BorderRadius.circular(25),
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 8.0, vertical: 4),
          //             child: Row(
          //               children: [
          //                 const Icon(Icons.group, size: 20),
          //                 const SizedBox(width: 4),
          //                 Text(
          //                   "Suppliers",
          //                   style: GoogleFonts.notoSansPhagsPa(
          //                       color: Colors.black, fontSize: 12),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 16),

          // Second Child: Row with Date Pickers and Dropdown
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffe3e7fa),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Start Date Picker
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: GestureDetector(
                        onTap: () =>
                            _selectDate(context, selectedStartDate, (date) {
                          setState(() {
                            selectedStartDate = date;
                          });
                        }),
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
                                style: GoogleFonts.notoSansPhagsPa(
                                    fontSize: 12, color: Colors.black),
                              ),
                              const Icon(Icons.calendar_today, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("To",
                        style: GoogleFonts.notoSansPhagsPa(
                            fontSize: 14, color: Colors.black)),
                    const SizedBox(width: 8),
                    // End Date Picker
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: GestureDetector(
                        onTap: () =>
                            _selectDate(context, selectedEndDate, (date) {
                          setState(() {
                            selectedEndDate = date;
                          });
                        }),
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
                                style: GoogleFonts.notoSansPhagsPa(
                                    fontSize: 12, color: Colors.black),
                              ),
                              const Icon(Icons.calendar_today, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Dropdown
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: SizedBox(
                        height: 30,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),

                            focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300)),
                            
                            enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300)), 
                                                 
                                
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          value: selectedDropdownValue,
                          hint: const Text(""),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDropdownValue = newValue;
                            });
                          },
                          items: ["Purchase", "Sale", "P. Return", "S. Return"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(value,
                                    style: GoogleFonts.notoSansPhagsPa(
                                        fontSize: 12, color: Colors.black)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TableView(),

          // Expanded(
          //   child: Consumer<PurchaseProvider>(
          //     builder: (context, provider, child) {
          //       if (provider.isLoading) {
          //         return const Center(child: CircularProgressIndicator());
          //       }

          //       final purchaseData = provider.purchaseData;

          //       // Check if null or empty
          //       if (purchaseData == null ||
          //           purchaseData.data == null ||
          //           purchaseData.data!.isEmpty) {
          //         return const Center(
          //           child: Text(
          //             'No Purchase data available',
          //             style: TextStyle(fontSize: 16),
          //           ),
          //         );
          //       }

          //       return ListView.builder(
          //         shrinkWrap: true,
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
          //         itemCount: provider.purchaseData!.data!.length,
          //         itemBuilder: (context, index) {
          //           final purchase = provider.purchaseData!.data![index];
          //           bool isEnabled = purchase.disabled == 'enable';

          //           return InkWell(
          //             onTap: () {},
          //             child: Card(
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12.0),
          //               ),
          //               elevation: 3,
          //               margin: const EdgeInsets.all(2),
          //               child: Padding(
          //                 padding: const EdgeInsets.symmetric(
          //                     horizontal: 8, vertical: 8),
          //                 child: Row(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     /// Left side: Supplier info
          //                     Expanded(
          //                       child: InkWell(
          //                         onTap: () {
          //                           Navigator.push(
          //                             context,
          //                             MaterialPageRoute(
          //                               builder: (context) =>
          //                                   PurchaseDetailsPage(
          //                                       purchase: purchase),
          //                             ),
          //                           );
          //                         },
          //                         child: Column(
          //                           crossAxisAlignment:
          //                               CrossAxisAlignment.start,
          //                           children: [
          //                             Text(
          //                               (purchase.supplier == 'N/A')
          //                                   ? 'Cash'
          //                                   : purchase.supplier!,
          //                               style: const TextStyle(
          //                                   fontSize: 14, color: Colors.black),
          //                             ),
          //                             Text('৳ ${purchase.grossTotal ?? 0}',
          //                                 style: const TextStyle(
          //                                     fontSize: 14,
          //                                     color: Colors.black)),
          //                             const Text('Payment:',
          //                                 style: TextStyle(
          //                                     fontSize: 14,
          //                                     color: Colors.black)),
          //                             const Text('Due:',
          //                                 style: TextStyle(
          //                                     fontSize: 14,
          //                                     color: Colors.black)),
          //                           ],
          //                         ),
          //                       ),
          //                     ),

          //                     /// Right side: Date, Bill No, Status, Actions
          //                     Container(
          //                       //color: Colors.green,
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.end,
          //                         children: [
          //                           Text('${purchase.billNumber}',
          //                               style: const TextStyle(
          //                                   fontSize: 14, color: Colors.black)),

          //                           //"pruchase_date": "2025-04-21",

          //                           // Text(
          //                           //   '${purchase.pruchaseDate}',
          //                           //   style: const TextStyle(
          //                           //       fontSize: 14, color: Colors.black),
          //                           // ),

          //                           Text(
          //                             formatDate(purchase.pruchaseDate),
          //                             style: const TextStyle(
          //                                 fontSize: 14, color: Colors.black),
          //                           ),

          //                           const SizedBox(height: 4),
          //                           //=>status , //=> edit  and update icon
          //                           Row(
          //                             mainAxisSize: MainAxisSize.min,
          //                             mainAxisAlignment:
          //                                 MainAxisAlignment.spaceAround,
          //                             children: [
          //                               Container(
          //                                 decoration: BoxDecoration(
          //                                   color: Colors.yellow.shade400,
          //                                   borderRadius:
          //                                       BorderRadius.circular(10),
          //                                 ),
          //                                 padding: const EdgeInsets.symmetric(
          //                                     vertical: 5, horizontal: 5),
          //                                 child: Text(
          //                                   purchase.transectionMethod!
          //                                               .toLowerCase() ==
          //                                           'cash'
          //                                       ? 'Paid'
          //                                       : 'Unpaid',
          //                                   style: TextStyle(
          //                                     fontWeight: FontWeight.bold,
          //                                     fontSize: 14,
          //                                     color: purchase.transectionMethod!
          //                                                 .toLowerCase() ==
          //                                             "cash"
          //                                         ? Colors.green
          //                                         : Colors.red,
          //                                   ),
          //                                 ),
          //                               ),
          //                               const SizedBox(width: 8),
          //                               Container(
          //                                 //color: Colors.teal,
          //                                 child: SizedBox(
          //                                   height: 20,
          //                                   width: 15,
          //                                   child: PopupMenuButton<String>(
          //                                     position: PopupMenuPosition.under,
          //                                     iconSize: 18,
          //                                     padding: EdgeInsets.zero,
          //                                     onSelected: (value) async {
          //                                       if (value == 'update' &&
          //                                           isEnabled) {
          //                                         Navigator.push(
          //                                           context,
          //                                           MaterialPageRoute(
          //                                             builder: (context) =>
          //                                                 PurchaseUpdateScreen(
          //                                               purchaseId: purchase
          //                                                   .purchaseDetails![0]
          //                                                   .purchaseId!,
          //                                             ),
          //                                           ),
          //                                         );
          //                                       } else if (value == 'delete') {
          //                                         bool isConfirmed =
          //                                             await _showDeleteConfirmationDialog(
          //                                                 context);
          //                                         if (isConfirmed) {
          //                                           await _deletePurchase(
          //                                               purchase
          //                                                   .purchaseDetails![0]
          //                                                   .purchaseId);
          //                                         }
          //                                       }
          //                                     },
          //                                     itemBuilder: (context) => [
          //                                       if (isEnabled)
          //                                         const PopupMenuItem(
          //                                           value: 'update',
          //                                           child: Row(
          //                                             children: [
          //                                               Icon(Icons.edit,
          //                                                   color: Colors.blue),
          //                                               SizedBox(width: 8),
          //                                               Text('Update'),
          //                                             ],
          //                                           ),
          //                                         ),
          //                                       const PopupMenuItem(
          //                                         value: 'delete',
          //                                         child: Row(
          //                                           children: [
          //                                             Icon(Icons.delete,
          //                                                 color: Colors.red),
          //                                             SizedBox(width: 8),
          //                                             Text('Delete'),
          //                                           ],
          //                                         ),
          //                                       ),
          //                                     ],
          //                                   ),
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // )
        ]),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Purchase",
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(" Confirm Delete"),
                ],
              ),
              content: const Text("Are you sure you want to delete this item?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
