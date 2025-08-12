import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/account/ui/expense/add_expense.dart';
import 'package:cbook_dt/feature/account/ui/expense/expence_edit.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/payment_out/provider/payment_out_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Expanse extends StatefulWidget {
  const Expanse({super.key});

  @override
  State<Expanse> createState() => _ExpanseState();
}

class _ExpanseState extends State<Expanse> {
  String? selectedDropdownValue;

  @override
  void initState() {
    super.initState();

    ///bill person
    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    ///fetch expense list.
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenseList();

    ///fetch acccount name.
    Provider.of<ExpenseProvider>(context, listen: false).fetchAccountNames();
  }

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

  ///formateDate
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
            Text(
              'Expense',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseCreate()));
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
              //const SizedBox(width: 8),

              const Spacer(),

              Consumer<ExpenseProvider>(
                builder: (context, provider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      'T. Expense: ৳ ${provider.totalExpense}',
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
          Consumer<ExpenseProvider>(builder: (context, provider, child) {
            final itemCount = provider.expenseList.length;
            return Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                'Total Voucher: $itemCount',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            );
          }),
          const SizedBox(
            height: 5,
          ),
          Consumer<ExpenseProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.expenseList.isEmpty) {
                return const Center(
                    child: Text(
                  'No expenses found.',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.expenseList.length,
                itemBuilder: (context, index) {
                  final expense = provider.expenseList[index];

                  final expenseId = expense.id.toString();

                  final accountName =
                      provider.accountNameMap[expense.accountID ?? 0] ??
                          'Account Not Found';

                  return InkWell(
                    onLongPress: () {
                      editDeleteDiolog(context, expenseId);
                    },
                    // onTap: () {
                    //   ///navigation to expense deatils page
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               const ExpanseDetails()));
                    // },
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero, // ✅ Set corner radius to zero
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Voucher Number
                                const Text(
                                  "Paid Form",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                ///
                                Text(
                                  expense.receivedTo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                /// Paid To
                                // Text(
                                //   expense.accountID == 1
                                //       ? 'Cash'
                                //       : expense.accountID == 11
                                //           ? 'Cash A'
                                //           : '${expense.accountID ?? 'Unknown'}', // fallback text
                                //   style: const TextStyle(
                                //     color: Colors.black,
                                //     fontSize: 12,
                                //   ),
                                // ),

                                // Text(
                                //   expense.accountID == 1
                                //       ? 'Cash'
                                //       : expense.accountID == 11
                                //           ? 'Cash A'
                                //           : expense.accountID == 2
                                //               ? 'Bank'
                                //               : expense.accountID == 13
                                //                   ? 'Bank A'
                                //                   : '${expense.accountID ?? 'Unknown'}',
                                //   style: const TextStyle(
                                //     color: Colors.black,
                                //     fontSize: 12,
                                //   ),
                                // ),

                                ////======>
                                // Text(
                                //   expense.receivedTo.toLowerCase() ==
                                //               'cash' ||
                                //           expense.receivedTo
                                //                   .toLowerCase() ==
                                //               'bank'
                                //       ? accountName
                                //       : expense.accountID
                                //           .toString(), // fallback
                                //   style: const TextStyle(
                                //     color: Colors.black,
                                //     fontSize: 12,
                                //   ),
                                // ),

                                const SizedBox(height: 2),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDate(expense.voucherDate),
                                      //'${expense.voucherDate}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '${expense.voucherNumber}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '${expense.totalAmount} ৳',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
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
    );
  }

  Future<dynamic> editDeleteDiolog(BuildContext context, String expenseId) {
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
                        builder: (context) => ExpenseEdit(expenseId: expenseId),
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
                    _showDeleteDialog(context, expenseId);
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

  void _showDeleteDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Expense',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Expense?',
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
                  Provider.of<ExpenseProvider>(context, listen: false);
              await provider.deleteExpense(expenseId.toString());
              await provider.fetchExpenseList(); // ✅ Re-fetch the latest list

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Successfully. Delete The Expense.')),
              );

              // Close dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
