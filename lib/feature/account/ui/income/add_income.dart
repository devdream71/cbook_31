import 'dart:convert';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/income/income_list.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_item.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_item.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IncomeCreate extends StatefulWidget {
  const IncomeCreate({super.key});

  @override
  State<IncomeCreate> createState() => _IncomeCreateState();
}

class _IncomeCreateState extends State<IncomeCreate> {
  String? selectedReceivedTo;
  String? selectedAccount;

  int? selectedAccountId;

  // Default to current date
  String? selectedDropdownValue;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  String billNo = '';
  String formattedDate = '';

  TextEditingController billController = TextEditingController();
  // TextEditingController billNoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch bill persons asynchronously
    Future.microtask(() {
      Provider.of<PaymentVoucherProvider>(context, listen: false)
          .fetchBillPersons();
    });

    // Set today's date after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<SalesController>(context, listen: false);

      if (controller.formattedDate2.isEmpty) {
        final now = DateTime.now();
        controller.formattedDate2 =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        setState(() {}); // 👈 make sure UI updates
      }
    });

    Future.microtask(() async {
      fetchAndSetBillNumber();
    });
  }

  // Updated fetchAndSetBillNumber with more debugging:
  // Future<void> fetchAndSetBillNumber() async {
  //   print('fetchAndSetBillNumber called');

  //   final url = Uri.parse(
  //     'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=voucher&type=indirect_income&code=IN&bill_number=100&with_nick_name=1',
  //   );

  //   print('API URL: $url');

  //   try {
  //     print('Making API call...');
  //     final response = await http.get(url);
  //     print('API Response Status: ${response.statusCode}');
  //     print('API Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print('Parsed data: $data');

  //       if (data['success'] == true && data['data'] != null) {
  //         String billFromApi = data['data'].toString(); // Ensure it's a string
  //         print('Bill from API: $billFromApi');

  //         //String newBill = _incrementBillNumber(billFromApi);

  //         String newBill = billFromApi;

  //         print('New bill after increment: $newBill');

  //         // Update the controller and trigger UI rebuild
  //         if (mounted) {
  //           setState(() {
  //             billController.text = newBill;
  //             print('Bill controller updated to: ${billController.text}');
  //           });
  //         }
  //       } else {
  //         print('API success false or data null');
  //         // Handle API error
  //         if (mounted) {
  //           setState(() {
  //             billController.text = "IN-101"; // Default fallback
  //             print('Set fallback bill: ${billController.text}');
  //           });
  //         }
  //       }
  //     } else {
  //       print('Failed to fetch bill number: ${response.statusCode}');
  //       // Set fallback bill number
  //       if (mounted) {
  //         setState(() {
  //           billController.text = "IN-101";
  //           print(
  //               'Set fallback bill due to status code: ${billController.text}');
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching bill number: $e');
  //     // Set fallback bill number
  //     if (mounted) {
  //       setState(() {
  //         billController.text = "IN-101";
  //         print('Set fallback bill due to exception: ${billController.text}');
  //       });
  //     }
  //   }
  // }



  ////=====> this is working. properly. plain text fetching the bill number fixed.
  
  // Future<void> fetchAndSetBillNumber() async {
  //   debugPrint('fetchAndSetBillNumber called');

  //   final url = Uri.parse(
  //     'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=voucher&type=indirect_income&code=IN&bill_number=100&with_nick_name=1',
  //   );

  //   debugPrint('API URL: $url');

  //   try {
  //     debugPrint('Making API call...');
  //     final response = await http.get(url);
  //     debugPrint('API Response Status: ${response.statusCode}');
  //     debugPrint('API Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final String billFromApi = response.body.trim(); // Just use plain text
  //       debugPrint('Bill from API: $billFromApi');

  //       if (billFromApi.isNotEmpty) {
  //         // Optional: extract only the number part
  //         String newBillNumber = billFromApi; //billFromApi.split('-').last.trim(); // "102"

  //         if (mounted) {
  //           setState(() {
  //             billController.text = newBillNumber;
  //             debugPrint('Bill controller updated to: ${billController.text}');
  //           });
  //         }
  //       } else {
  //         _setFallback();
  //       }
  //     } else {
  //       debugPrint('Failed to fetch bill number: ${response.statusCode}');
  //       _setFallback();
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching bill number: $e');
  //     _setFallback();
  //   }
  // }

  // void _setFallback() {
  //   if (mounted) {
  //     setState(() {
  //       billController.text = "100"; // Fallback number only
  //       debugPrint('Set fallback bill due to error: ${billController.text}');
  //     });
  //   }
  // }



  ///updated bill nunber json respoonse
  Future<void> fetchAndSetBillNumber() async {
  print('fetchAndSetBillNumber called');

  final url = Uri.parse(
    'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=voucher&type=indirect_income&code=IN&bill_number=100&with_nick_name=1',
  );

  try {
    print('Making API call...');
    final response = await http.get(url);
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Parsed data: $data');

      if (data['success'] == true && data['data'] != null) {
        final billFromApi = data['data']['bill_number']?.toString().trim() ?? "";

        print('Bill from API: $billFromApi');

        // Optional: extract only number from "IN-102"
        final billOnlyNumber =  billFromApi;

        if (mounted) {
          setState(() {
            billController.text = billOnlyNumber;
            print('Bill controller updated to: ${billController.text}');
          });
        }
      } else {
        print('API success false or data missing');
        _setFallback();
      }
    } else {
      print('Failed to fetch bill number: ${response.statusCode}');
      _setFallback();
    }
  } catch (e) {
    print('Error fetching bill number: $e');
    _setFallback();
  }
}

void _setFallback() {
  if (mounted) {
    setState(() {
      billController.text = "101"; // or any default you want
      print('Fallback bill set: ${billController.text}');
    });
  }
}


  @override
  void dispose() {
    // Clear receipt items when leaving the page
    final providerIncome = Provider.of<IncomeProvider>(context, listen: false);
    providerIncome.clearReceiptItems();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    final provider = context.watch<IncomeProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          provider.clearReceiptItems();
        }
      },
      child: Scaffold(
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
                'Income Create',
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
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ///1 section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///received to
                    SizedBox(
                      height: 30,
                      width: 150,
                      child: CustomDropdownTwo(
                        hint: '',
                        items: const ['Cash in Hand', 'Bank'],
                        width: double.infinity,
                        height: 30,
                        labelText: 'Received to',
                        selectedItem: selectedReceivedTo,
                        onChanged: (value) async {
                          debugPrint('=== Received To Selected: $value ===');

                          setState(() {
                            selectedReceivedTo = value;
                            selectedAccount = null; // reset account selection
                          });

                          if (value == 'Cash in Hand') {
                            debugPrint('Fetching Cash accounts...');
                            await provider.fetchAccounts('cash');
                          } else if (value == 'Bank') {
                            debugPrint('Fetching Bank accounts...');
                            await provider.fetchAccounts('bank');
                          }

                          debugPrint(
                              'Fetched Account Names: ${provider.accountNames}');
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Account Dropdown
                    SizedBox(
                      height: 30,
                      width: 150,
                      child: provider.isAccountLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomDropdownTwo(
                              hint: '',
                              items: provider.accountNames,
                              width: double.infinity,
                              height: 30,
                              labelText: 'A/C',
                              selectedItem: selectedAccount,
                              onChanged: (value) {
                                debugPrint('=== Account Selected: $value ===');
                                setState(() {
                                  selectedAccount = value;
                                });

                                if (provider.accountModel != null) {
                                  final selectedAccountData = provider
                                      .accountModel!.data
                                      .firstWhere((account) =>
                                          account.accountName == value);

                                  selectedAccountId = selectedAccountData.id;

                                  debugPrint(
                                      '=== Account Selected: $value ===');
                                  if (selectedAccountId != null) {
                                    debugPrint(
                                        'Selected Account ID: $selectedAccountId');
                                  }

                                  debugPrint('Selected Account Details:');
                                  debugPrint('- ID: ${selectedAccountData.id}');
                                  debugPrint(
                                      '- Name: ${selectedAccountData.accountName}');
                                  debugPrint('- Type: $selectedReceivedTo');
                                }
                              },
                            ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //bill person
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Consumer<PaymentVoucherProvider>(
                        builder: (context, provider, child) {
                          return SizedBox(
                            height: 30,
                            width: 130,
                            child: provider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CustomDropdownTwo(
                                    hint: '',
                                    items: provider.billPersonNames,
                                    width: double.infinity,
                                    height: 30,
                                    labelText: 'Bill Person',
                                    selectedItem: selectedBillPerson,
                                    onChanged: (value) {
                                      debugPrint(
                                          '=== Bill Person Selected: $value ===');
                                      setState(() {
                                        selectedBillPerson = value;
                                        selectedBillPersonData =
                                            provider.billPersons.firstWhere(
                                          (person) => person.name == value,
                                        ); // ✅ Save the whole object globally
                                        selectedBillPersonId =
                                            selectedBillPersonData!.id;
                                      });

                                      debugPrint(
                                          'Selected Bill Person Details:');
                                      debugPrint(
                                          '- ID: ${selectedBillPersonData!.id}');
                                      debugPrint(
                                          '- Name: ${selectedBillPersonData!.name}');
                                      debugPrint(
                                          '- Phone: ${selectedBillPersonData!.phone}');
                                    }),
                          );
                        },
                      ),
                    ),

                    // Bill No Field

                    const SizedBox(
                      height: 8,
                    ),

                    ///bill no,
                    // SizedBox(
                    //   height: 30,
                    //   width: 130,
                    //   child: AddSalesFormfield(
                    //     labelText: "Bill No",
                    //     controller: billNoController,

                    //     onChanged: (value) {
                    //       billNo = value;
                    //     }, // Match cursor height to text size
                    //   ),
                    // ),

                    SizedBox(
                      height: 30,
                      width: 130,
                      child: AddSalesFormfield(
                        labelText: "Bill No",
                        controller: billController,
                        readOnly: true, // Prevent manual editing
                      ),
                    ),

                    ///bill date.
                    SizedBox(
                      height: 30,
                      width: 130,
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            final formatted =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

                            setState(() {
                              controller.formattedDate2 =
                                  formatted; // ✅ update UI
                            });

                            debugPrint("📅 Selected Bill Date: $formatted");
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            isDense: true,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            hintText: "Bill Date",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 9,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 0.5),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          child: Text(
                            controller.formattedDate2.isNotEmpty
                                ? controller.formattedDate2
                                : "Select Date",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(
              height: 6,
            ),

            ///item index, item name, note here.
            if (provider.receiptItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: provider.receiptItems.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Index number
                          Text(
                            '$index.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),

                          /// Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Title
                                Text(
                                  item.receiptFrom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 1),

                                /// Note
                                Text(
                                  item.note,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          /// Amount and Delete Button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.amount.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 13,
                                    child: Icon(Icons.close, size: 20)),
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                    context: context,
                                    onConfirm: () {
                                      setState(() {
                                        provider.receiptItems.remove(item);
                                        provider.notifyListeners();
                                      });
                                    },
                                  );
                                  // setState(() {
                                  //   provider.receiptItems.remove(item);
                                  //   provider.notifyListeners();
                                  // });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 6),

            ///2 section
            InkWell(
              onTap: () async {
                await provider
                    .fetchReceiptFromList(); // 🔥 Fetch API before showing dialog
                showIncomeCreateDialog(
                  context,
                  provider,
                ); // Pass provider
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Receipt From",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Total Amount Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Total: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      Text(
                        provider.receiptItems.fold<double>(
                          0,
                          (sum, item) {
                            // parse amount string safely to double
                            final amt =
                                double.tryParse(item.amount.toString()) ?? 0.0;
                            return sum + amt;
                          },
                        ).toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                ///save income.
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? userId = prefs.getInt('user_id')?.toString();

                      if (userId == null) {
                        debugPrint("User ID is null");
                        return;
                      }

                      final invoiceNo = billController.text.trim();
                      // const date =
                      //     "2025-06-10"; // your date string like '2025-06-10'

                      final receivedTo =
                          (selectedReceivedTo ?? '').toLowerCase();
                      final account = selectedAccountId.toString();
                      const notes = 'text'; // Or from your input field
                      final billPersonID = selectedBillPersonData!.id;

                      const status = 1;

                      final totalAmount = provider.receiptItems.fold<double>(
                        0,
                        (sum, item) =>
                            sum +
                            (double.tryParse(item.amount.toString()) ?? 0),
                      );

                      // Prepare income items with correct account_id (use your actual accountId)
                      final List<IncomeItem> incomeItems =
                          provider.receiptItems.map((item) {
                        return IncomeItem(
                          accountId:
                              account, // or item-specific account id if different
                          narration: item.note,
                          amount: item.amount.toString(),
                        );
                      }).toList();

                      // 👉 Print all sending data
                      debugPrint('Sending Data:');
                      debugPrint('User ID: $userId');
                      debugPrint('Expense No: $invoiceNo');
                      //debugPrint('Date: $date');
                      debugPrint('Paid To: $receivedTo');
                      debugPrint('Account: $account');
                      debugPrint('Total Amount: $totalAmount');
                      debugPrint('Notes: $notes');
                      debugPrint('Status: $status');
                      debugPrint(" bill  person ${billPersonID}");
                      debugPrint(
                          "📅 Selected Bill Date: ${controller.formattedDate2}");
                      debugPrint(
                          'income Items: ${incomeItems.map((e) => e.toJson()).toList()}');

                      bool success = await provider.storeIncome(
                        userId: userId,
                        invoiceNo: invoiceNo,
                        date: controller.formattedDate2,
                        receivedTo: receivedTo,
                        account: account,
                        totalAmount: totalAmount,
                        notes: notes,
                        status: status,
                        incomeItems: incomeItems,
                        billPersonID: billPersonID.toString(),
                      );

                      if (success) {
                        provider.receiptItems.clear();
                        provider.notifyListeners();

                        await provider.fetchIncomeList();

                        // Navigate to Income page (replace with your actual route)
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Income()));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Successfully. Save  The income.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to save income.')),
                        );
                      }
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            )
          ]),
        ),
      ),
    );
  }

  void showIncomeCreateDialog(
    BuildContext context,
    IncomeProvider provider,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController amountController = TextEditingController();
        TextEditingController noteController = TextEditingController();
        String? selectedReceiptFrom;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(6.0),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      color: const Color(0xff278d46),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width:
                                  30), // Placeholder for left spacing (can be removed or adjusted)

                          // Centered text and icon
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text(
                                "Receipt From",
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.grey.shade100,
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.green,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 30,
                      child: provider.isReceiptLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomDropdownTwo(
                              hint: '',
                              items: provider.receiptFromNames,
                              width: double.infinity,
                              height: 30,
                              labelText: 'Receipt From',
                              selectedItem: selectedReceiptFrom,
                              onChanged: (selectedItem) {
                                debugPrint(
                                    'Selected Receipt From: $selectedItem');
                                setState(() {
                                  selectedReceiptFrom = selectedItem;
                                });
                              },
                            ),
                    ),
                    AddSalesFormfield(
                      label: "",
                      labelText: "Amount",
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                    ),
                    AddSalesFormfield(
                      label: "",
                      labelText: "Note",
                      controller: noteController,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // TextButton(
                        //   onPressed: () {
                        //     if (selectedReceiptFrom != null &&
                        //         amountController.text.isNotEmpty) {
                        //       provider.addReceiptItem(ReceiptItem(
                        //         receiptFrom: selectedReceiptFrom!,
                        //         amount: amountController.text,
                        //         note: noteController.text,
                        //       ));
                        //       amountController.clear();
                        //       noteController.clear();
                        //       setState(() {
                        //         selectedReceiptFrom = null;
                        //       });
                        //     }
                        //   },
                        //   child: const Text('Add & New'),
                        // ),

                        TextButton(
                          onPressed: () {
                            if (selectedReceiptFrom != null &&
                                amountController.text.isNotEmpty) {
                              provider.addReceiptItem(ReceiptItem(
                                receiptFrom: selectedReceiptFrom!,
                                amount: amountController.text,
                                note: noteController.text,
                              ));
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //remove item
  void showDeleteConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Remove?"),
        content: const Text(
          "Are you sure you want to remove the item?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onConfirm(); // Run the actual delete
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
