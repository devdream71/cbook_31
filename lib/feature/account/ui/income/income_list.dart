import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/account/ui/income/add_income.dart';
import 'package:cbook_dt/feature/account/ui/income/income_details.dart';
import 'package:cbook_dt/feature/account/ui/income/income_edit.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  @override
  void initState() {
    super.initState();

    //final incomeProvider = Provider.of(context)<IncomeProvider>(context, listen: false);
    Provider.of<IncomeProvider>(context, listen: false).fetchIncomeList();
    Provider.of<IncomeProvider>(context, listen: false).fetchAccountNames();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                'Income',
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
                        builder: (context) => const IncomeCreate()));
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///top date start , end and dropdown
            Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Consumer<IncomeProvider>(
                  builder: (context, provider, _) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total Income: ৳ ${provider.totalIncome}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),

                Consumer<IncomeProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.incomeModel == null ||
                        provider.incomeModel!.data.isEmpty) {
                      return const Center(
                          child: Text(
                        'No Income Found',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ));
                    }

                    final incomes = provider.incomeModel!.data;

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: incomes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 1), // 🔥 1px space
                      itemBuilder: (context, index) {
                        final income = incomes[index];
                        final incomeId = income.id.toString();

                        final accountName =
                            provider.accountNameMap[income.accountId ?? 0] ??
                                'Account Not Found';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: InkWell(
                            onLongPress: () {
                              editDeleteDiolog(context, incomeId);
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const IncomeDetails()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffe3e7fa),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 4.0),
                                child: Row(
                                  children: [
                                    /// Left side
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Received To",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          income.receivedTo.toLowerCase() ==
                                                  'cash'
                                              ? 'Cash In Hand'
                                              : income.receivedTo
                                                          .toLowerCase() ==
                                                      'bank'
                                                  ? 'Bank'
                                                  : income.receivedTo,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),

                                        //income.receivedTo == 'bank' ?
                                        // Text(
                                        //   income.accountId.toString(),
                                        //   style: const TextStyle(
                                        //     color: Colors.black,
                                        //     fontSize: 12,
                                        //   ),
                                        // ),

                                        Text(
                                          income.receivedTo.toLowerCase() ==
                                                      'cash' ||
                                                  income.receivedTo
                                                          .toLowerCase() ==
                                                      'bank'
                                              ? accountName
                                              : income.accountId
                                                  .toString(), // fallback
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    /// Right side
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              income.voucherDate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              income.voucherNumber,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              income.totalAmount.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),

            ///Bottom
          ],
        ));
  }

  ///delete and edit show
  Future<dynamic> editDeleteDiolog(BuildContext context, String incomeId) {
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
                    ),
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
                        builder: (context) => IncomeEdit(incomeId: incomeId),
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
                    _showDeleteDialog(context, incomeId);
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

  ///delete
  void _showDeleteDialog(BuildContext context, String incomeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Income',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this income?',
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
                  Provider.of<IncomeProvider>(context, listen: false);
              await provider.deleteIncome(incomeId.toString());
              await provider
                  .fetchReceiptFromList(); // ✅ Re-fetch the latest list

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Successfully. Delete The income.')),
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

class AccountModel {
  final int id;
  final String accountName;

  AccountModel({required this.id, required this.accountName});
}
