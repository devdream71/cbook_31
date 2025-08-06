import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales_return/presentation/sales_return_view.dart';
import 'package:cbook_dt/feature/sales_return/provider/sale_return_provider.dart';
import 'package:cbook_dt/feature/sales_return/sales_return_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SalesReturnProvider>(context, listen: false);
    provider.fetchSalesReturn();
    provider.fetchItems();
  }

  final TextEditingController _searchController = TextEditingController();

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

  ///start date.
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  ///end date.
  DateTime selectedEndDate = DateTime.now();

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SalesReturnProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        title: const Text(
          "Sales Return list",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        backgroundColor: colorScheme.primary,
        leading: const BackButton(color: Colors.white),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SalesReturnView()),
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
                  SizedBox(width: 3),
                  Text(
                    'Sales Return',
                    style: TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ///month start date
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: GestureDetector(
                  onTap: () => _selectDate(context, selectedStartDate, (date) {
                    setState(() {
                      selectedStartDate = date;
                    });
                  }),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
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
              const SizedBox(width: 2),
              Text("-",
                  style: GoogleFonts.notoSansPhagsPa(
                      fontSize: 14, color: Colors.black)),
              const SizedBox(width: 8),
              // current date Picker
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: GestureDetector(
                  onTap: () => _selectDate(context, selectedEndDate, (date) {
                    setState(() {
                      selectedEndDate = date;
                    });
                  }),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      // border:
                      //     Border.all(color: Colors.grey.shade300),
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

              const Spacer(),

              Consumer<SalesReturnProvider>(
                builder: (context, provider, child) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Text(
                      'T. S. Return: ৳${provider.totalReturn.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Consumer<SalesReturnProvider>(builder: (context, provider, child) {
            final itemCount = provider.salesReturns.length;
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'Total Bill: ${itemCount.toString()}',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            );
          }),
          Expanded(
            child: provider.isLoading
                ? Consumer<SalesReturnProvider>(
                    builder: (context, provider, child) {
                    return const Center(child: CircularProgressIndicator());
                  })
                : provider.salesReturns.isEmpty
                    ? const Center(
                        child: Text(
                          "No sales return data available.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ListView.builder(
                          itemCount: provider.salesReturns.length,
                          itemBuilder: (context, index) {
                            final item = provider.salesReturns[index];

                            final salesReturnId =
                                provider.salesReturns[index].id;

                            return InkWell(
                              onLongPress: () {
                                editDeleteDiolog(
                                    context, salesReturnId.toString());
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesReturnDetailsPage(
                                        salesReturn: item),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDate(item.purchaseDate),

                                              // item.purchaseDate != null
                                              //     ? item.purchaseDate!
                                              //     : 'No Date',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              item.billNumber,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Divider
                                      Container(
                                        height: 45,
                                        width: 2,
                                        color: Colors.green.shade200,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.supplierName == "N/A"
                                                ? "Cash"
                                                : item.supplierName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "৳ ${item.grossTotal}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),

                                      const Spacer(),

                                      // Unpaid tag
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  ///edit delete diolog
  Future<dynamic> editDeleteDiolog(BuildContext context, String salesReturnId) {
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
                    _showDeleteDialog(context, salesReturnId);
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
  void _showDeleteDialog(BuildContext context, String salesReturnId) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<SalesReturnProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Sales Return',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Sales Return?',
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
              await provider.deleteSalesReturn(
                  int.tryParse(salesReturnId), context);
              await provider.fetchSalesReturn();

              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
