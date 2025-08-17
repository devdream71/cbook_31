import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/bill_voucher_settings/provider/bill_settings_provider.dart';
import 'package:cbook_dt/feature/customer_create/model/payment_voicer_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/payment_out/model/bill_person_list_model.dart';
import 'package:cbook_dt/feature/payment_out/model/create_payment_out_model.dart';
import 'package:cbook_dt/feature/payment_out/payment_out_list.dart';
import 'package:cbook_dt/feature/payment_out/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentOutCreateItem extends StatefulWidget {
  const PaymentOutCreateItem({super.key});

  @override
  State<PaymentOutCreateItem> createState() => _PaymentOutCreateItemState();
}

class _PaymentOutCreateItemState extends State<PaymentOutCreateItem> {
  TextEditingController billController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  Map<int, TextEditingController> receiptControllers = {};
  TextEditingController billNoController = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();

  TextEditingController customerNameController = TextEditingController();

  String billNo = '';
  bool showNoteField = false;

  TextEditingController discountAmount = TextEditingController();
  TextEditingController paymentAmount = TextEditingController();

  TextEditingController noteController = TextEditingController();

  // ✅ Add these boolean flags to prevent infinite loops (add to your class variables)
  bool _isUpdatingFromPercentage = false;
  bool _isUpdatingFromAmount = false;

  String? selectedReceivedTo;
  String? selectedAccount;

  //String? selectedReceivedTo;     // e.g. 'Cash in Hand'
  String? internalReceivedTo;

  int? selectedAccountId;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  //String? selectedDiscountType;

  String selectedDiscountType = '%'; // default '%'
  double dueAmount = 0;

  DateTime selectedStartDate = DateTime.now();
  // Default to current date
  DateTime selectedEndDate = DateTime.now();
  // Default to current date
  String? selectedDropdownValue;

  Set<int> expandedIndexes = {};

  // You should assign this when customer selected or invoice loaded

  String getReceivedToValue(String label) {
    if (label == 'Cash in Hand') return 'cash';
    if (label == 'Bank') return 'bank';
    return ''; // fallback if needed
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

  // ✅ Store the selected object globally

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr();

      Provider.of<PaymentVoucherProvider>(context, listen: false)
          .fetchBillPersons();

     
          

      //await fetchAndSetBillNumber();
    });

    // Initialize with loading text
    billController.text = "Loading...";
    debugPrint('Bill controller initialized with: ${billController.text}');

    Future.microtask(() async {
      // First fetch settings and wait for completion
      await Provider.of<BillSettingsProvider>(context, listen: false)
          .fetchSettings();
      debugPrint('Settings fetched successfully');
      await fetchAndSetBillNumber(context);
    });



  }

  @override
  void dispose() {
    discountPercentageController.dispose();
    // ... other disposals
    super.dispose();
  }


  Future<void> fetchAndSetBillNumber(BuildContext context) async {
    debugPrint('fetchAndSetBillNumber called');

    final settingsProvider =
        Provider.of<BillSettingsProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Fetch required values from provider (now they should be available)
    final code = settingsProvider.getValue("payment_code") ?? "";
    final billNumber =
        settingsProvider.getValue("payment_bill_no") ?? "";
    final withNickName = settingsProvider.getValue("with_nick_name") ?? "0";

    debugPrint(
        'Settings values - code: $code, billNumber: $billNumber, withNickName: $withNickName');

    final url = Uri.parse(
      '${AppUrl.baseurl}app/setting/bill/number'
      '?voucher_type=voucher'
      '&type=payment'
      '&code=$code'
      '&bill_number=$billNumber'
      '&with_nick_name=$withNickName',
    );

    debugPrint('API URL: =====> $url');

    try {
      debugPrint('Making API call...');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Parsed data: $data');

        if (data['success'] == true && data['data'] != null) {
          String billFromApi = data['data']['bill_number'].toString();
          debugPrint('Bill from API: $billFromApi');

          if (mounted) {
            setState(() {
              billController.text = billFromApi;
              debugPrint('Bill controller updated to: ${billController.text}');
            });
          }
          return;
        }
      }

      // API failed or returned no usable data
      if (mounted) {
        setState(() {
          billController.text = code.isNotEmpty ? "$code-100" : "PAY-100";
          debugPrint('Fallback bill set to: ${billController.text}');
        });
      }
    } catch (e) {
      debugPrint('Error fetching bill number: $e');
      if (mounted) {
        setState(() {
          billController.text = code.isNotEmpty ? "$code-100" : "PAY-100";
          debugPrint('Fallback bill set to: ${billController.text}');
        });
      }
    }
  }


  ///updated bill nunber json respoonse
  // Future<void> fetchAndSetBillNumber(context) async {
  //   debugPrint('fetchAndSetBillNumber called');

  //   final url = Uri.parse(
  //     '${AppUrl.baseurl}app/setting/bill/number?voucher_type=voucher&type=payment&code=PAY&bill_number=100&with_nick_name=1',
  //   );

  //   try {
  //     debugPrint('Making API call...');
  //     final response = await http.get(url);
  //     debugPrint('API Response Status: ${response.statusCode}');
  //     debugPrint('API Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       debugPrint('Parsed data: $data');

  //       if (data['success'] == true && data['data'] != null) {
  //         final billFromApi =
  //             data['data']['bill_number']?.toString().trim() ?? "";

  //         debugPrint('Bill from API: $billFromApi');

  //         // Optional: extract only number from "PAY-100"
  //         final billOnlyNumber = billFromApi;

  //         if (mounted) {
  //           setState(() {
  //             billController.text = billOnlyNumber;
  //             debugPrint('Bill controller updated to: ${billController.text}');
  //           });
  //         }
  //       } else {
  //         debugPrint('API success false or data missing');
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
  //       billController.text = "PAY-100"; // or any default you want
  //       debugPrint('Fallback bill set: ${billController.text}');
  //     });
  //   }
  // }

  /// Calculate sum of all receipts input
  double get totalReceiptAmount {
    double total = 0;
    for (final c in receiptControllers.values) {
      total += double.tryParse(c.text) ?? 0;
    }
    return total;
  }

  /// Called when discount or receipt amounts change

  // ✅ Updated _recalculatePayment method
  void _recalculatePayment() {
    double due = totalReceiptAmount; // total receipt entered by user

    final discountText = discountAmount.text.trim();
    double discountValue = double.tryParse(discountText) ?? 0;

    if (due <= 0) {
      paymentAmount.text = "0.00";
      totalAmount.text = "0.00";
      // ✅ Clear percentage when total is 0
      discountPercentageController.clear();
      return;
    }

    // Clamp discount value
    if (selectedDiscountType == '%') {
      if (discountValue > 100) discountValue = 100;
    } else {
      if (discountValue > due) discountValue = due;
    }

    double discountAmountCalculated = selectedDiscountType == '%'
        ? (discountValue / 100) * due
        : discountValue;

    double finalPayment = due - discountAmountCalculated;

    if (finalPayment < 0) finalPayment = 0;

    setState(() {
      totalAmount.text = due.toStringAsFixed(2); // show total before discount
      paymentAmount.text = finalPayment.toStringAsFixed(2);
    });

    debugPrint(
      'Total Receipt: $due, Discount: $discountValue $selectedDiscountType, '
      'Discount Amt: $discountAmountCalculated, Final Payment: $finalPayment',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    //final provider = Provider.of<IncomeProvider>(context);
    final provider = context.watch<IncomeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Column(
          children: [
            Text(
              'Payment out Create',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ///1 section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///payment form
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: CustomDropdownTwo(
                      hint: '',
                      items: const ['Cash in Hand', 'Bank'],
                      width: double.infinity,
                      height: 30,
                      labelText: 'Payment From',
                      selectedItem: selectedReceivedTo,
                      onChanged: (value) async {
                        // debugPrint('=== Received To Selected: $value ===');

                        debugPrint('=== Received To Selected: $value ===');

                        setState(() {
                          selectedReceivedTo = value;
                          selectedAccount = null;

                          internalReceivedTo =
                              value == 'Cash in Hand' ? 'cash' : 'bank';
                        });

                        if (internalReceivedTo == 'cash') {
                          debugPrint('Fetching Cash accounts...');
                          await provider.fetchAccounts('cash');
                        } else if (internalReceivedTo == 'bank') {
                          debugPrint('Fetching Bank accounts...');
                          await provider.fetchAccounts('bank');
                        }

                        debugPrint(
                            'Fetched Account Names: ${provider.accountNames}');
                        debugPrint(
                            'selectedReceivedTo ===> $selectedReceivedTo <======');
                        debugPrint(
                            'internalReceivedTo (to use/send) ===> $internalReceivedTo');
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

                                debugPrint('=== Account Selected: $value ===');
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
                  // Inside your build method:

                  // Padding(
                  //   padding: const EdgeInsets.only(top: 8.0),
                  //   child: Consumer<PaymentVoucherProvider>(
                  //     builder: (context, provider, child) {
                  //       return SizedBox(
                  //         height: 30,
                  //         width: 130,
                  //         child: provider.isLoading
                  //             ? const Center(child: CircularProgressIndicator())
                  //             : CustomDropdownTwo(
                  //                 hint: '',
                  //                 items: provider.billPersonNames,
                  //                 width: double.infinity,
                  //                 height: 30,
                  //                 labelText: 'Bill Person',
                  //                 selectedItem: selectedBillPerson,
                  //                 onChanged: (value) {
                  //                   debugPrint(
                  //                       '=== Bill Person Selected: $value ===');
                  //                   setState(() {
                  //                     selectedBillPerson = value;
                  //                     selectedBillPersonData =
                  //                         provider.billPersons.firstWhere(
                  //                       (person) => person.name == value,
                  //                     ); // ✅ Save the whole object globally
                  //                     selectedBillPersonId =
                  //                         selectedBillPersonData!.id;
                  //                   });

                  //                   debugPrint('Selected Bill Person Details:');
                  //                   debugPrint(
                  //                       '- ID: ${selectedBillPersonData!.id}');
                  //                   debugPrint(
                  //                       '- Name: ${selectedBillPersonData!.name}');
                  //                   debugPrint(
                  //                       '- Phone: ${selectedBillPersonData!.phone}');
                  //                 }),
                  //       );
                  //     },
                  //   ),
                  // ),

                  // Bill No Field

                  const SizedBox(
                    height: 8,
                  ),

                  ///bill no, bill person

                  SizedBox(
                    height: 30,
                    width: 130,
                    child: AddSalesFormfield(
                      labelText: "Bill No",
                      controller: billController,
                      readOnly: true, // Prevent manual editing
                    ),
                  ),

                  //person

                  ///bill date
                  SizedBox(
                    height: 30,
                    width: 130,
                    child: InkWell(
                      // onTap: () => controller.pickDate(
                      //     context), // Trigger the date picker
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
                          ), // Adjust constraints to align icon closely
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
                          controller.formattedDate.isNotEmpty
                              ? controller.formattedDate
                              : "Select Date", // Default text when no date is selected
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
            height: 8,
          ),

          const Center(
            child: Text(
              "Payment To",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),

          /// Customer search field
          AddSalesFormfieldTwo(
            controller: customerNameController,
            customerorSaleslist: "Showing Customer list",
            customerOrSupplierButtonLavel: "",
            color: Colors.grey,
            onTap: () {
              // Add your customer selection logic
            },
          ),

          /// Show customer payable/receivable if selected
          Consumer<CustomerProvider>(
            builder: (context, customerProvider, child) {
              final customerList =
                  customerProvider.customerResponse?.data ?? [];
              final selectedCustomer = customerProvider.selectedCustomer;

              ///voucher_items
              ///sales_id
              ///amount
              ///from here get sales id and amount for the vouceher items

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customerList.isEmpty) const SizedBox(height: 2),
                  if (customerList.isNotEmpty &&
                      selectedCustomer != null &&
                      selectedCustomer.id != -1) ...[
                    SizedBox(
                      height: 300,
                      child: customerProvider.paymentVouchers.isEmpty
                          ? const Center(
                              child: Text(
                                "No voucher found.",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              itemCount:
                                  customerProvider.paymentVouchers.length,
                              itemBuilder: (context, index) {
                                final PaymentVoucherCustomer invoice =
                                    customerProvider.paymentVouchers[index];
                                final bool isExpanded =
                                    expandedIndexes.contains(index);

                                debugPrint(
                                    'paymeny out sales Id == ${invoice.id.toString()}');

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 1),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3)),
                                    elevation: 1,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isExpanded) {
                                            expandedIndexes.remove(index);
                                          } else {
                                            expandedIndexes.add(index);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0, vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Top Row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(invoice.billNumber,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black)),
                                                Text(invoice.purchaseDate,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black)),
                                                Text(
                                                    'Bill ৳${invoice.grossTotal}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black)),
                                                Text('Due ৳${invoice.due}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black)),
                                                Icon(
                                                  isExpanded
                                                      ? Icons.arrow_drop_up
                                                      : Icons.arrow_drop_down,
                                                  size: 28,
                                                ),
                                              ],
                                            ),

                                            if (isExpanded) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  const Text('Payment',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    height: 30,
                                                    width: 150,
                                                    child: TextFormField(
                                                      controller:
                                                          receiptControllers[
                                                                  index] ??=
                                                              TextEditingController(),
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        final input =
                                                            double.tryParse(
                                                                    value) ??
                                                                0;
                                                        final due = invoice.due;

                                                        if (input > due) {
                                                          // Clamp to due
                                                          receiptControllers[
                                                                      index]!
                                                                  .text =
                                                              due.toStringAsFixed(
                                                                  2);
                                                          receiptControllers[
                                                                      index]!
                                                                  .selection =
                                                              TextSelection
                                                                  .fromPosition(
                                                            TextPosition(
                                                                offset: receiptControllers[
                                                                        index]!
                                                                    .text
                                                                    .length),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Amount can’t exceed due: ৳${due.toStringAsFixed(2)}'),
                                                              backgroundColor:
                                                                  Colors.red,
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                        }

                                                        // ✅ Always recalculate total
                                                        double total = 0;
                                                        for (final controller
                                                            in receiptControllers
                                                                .values) {
                                                          total += double.tryParse(
                                                                  controller
                                                                      .text) ??
                                                              0;
                                                        }
                                                        totalAmount.text = total
                                                            .toStringAsFixed(2);

                                                        _recalculatePayment();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ]
                ],
              );
            },
          ),

          const Spacer(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.note_add_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  setState(() {
                    showNoteField = !showNoteField;
                  });
                },
              ),
              if (showNoteField)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                color: Colors.grey.shade400, width: 1),
                            bottom: BorderSide(
                                color: Colors.grey.shade400, width: 1),
                            left: BorderSide(
                                color: Colors.grey.shade400, width: 1),
                            right: BorderSide(
                                color: Colors.grey.shade400, width: 1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: TextField(
                          controller: noteController,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          onChanged: (value) {
                            noteController.text = value;
                          },
                          maxLines: 2,
                          cursorHeight: 12,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "Note",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          ///total amount
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // 🔥 Right align labels + fields
              children: [
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Total Amount", style: ts),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        labelText: "Amount",
                        readOnly: true,
                        controller: totalAmount,
                        onChanged: (value) {
                          debugPrint('Payment Value: ${totalAmount.text}');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Discount row with % dropdown and text field

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Discount", style: ts),
                    const SizedBox(width: 10),

                    // Percentage field
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: AddSalesFormfield(
                        labelText: "%",
                        controller: discountPercentageController,
                        onChanged: (value) {
                          // ✅ Prevent infinite loops by checking if we're updating from amount field
                          if (_isUpdatingFromAmount) return;

                          _isUpdatingFromPercentage = true;

                          // Calculate amount based on percentage
                          if (value.isNotEmpty) {
                            double percentage = double.tryParse(value) ?? 0.0;

                            // ✅ Clamp percentage to 0-100
                            if (percentage > 100) {
                              percentage = 100;
                              discountPercentageController.text = "100";
                            }

                            double totalAmountValue =
                                totalReceiptAmount; // ✅ Use your existing variable
                            double calculatedAmount =
                                (totalAmountValue * percentage) / 100;
                            discountAmount.text =
                                calculatedAmount.toStringAsFixed(2);

                            // ✅ Update selectedDiscountType for your existing logic
                            selectedDiscountType = '%';
                          } else {
                            discountAmount.clear();
                          }

                          _isUpdatingFromPercentage = false;
                          _recalculatePayment();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Amount field
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: AddSalesFormfield(
                        labelText: "Amount",
                        controller: discountAmount,
                        onChanged: (value) {
                          // ✅ Prevent infinite loops by checking if we're updating from percentage field
                          if (_isUpdatingFromPercentage) return;

                          _isUpdatingFromAmount = true;

                          // Calculate percentage based on amount
                          if (value.isNotEmpty) {
                            double amount = double.tryParse(value) ?? 0.0;
                            double totalAmountValue =
                                totalReceiptAmount; // ✅ Use your existing variable

                            if (totalAmountValue > 0) {
                              double calculatedPercentage =
                                  (amount * 100) / totalAmountValue;

                              // ✅ Clamp percentage to 0-100
                              if (calculatedPercentage > 100) {
                                calculatedPercentage = 100;
                                amount =
                                    totalAmountValue; // Set amount to max (100%)
                                discountAmount.text = amount.toStringAsFixed(2);
                              }

                              discountPercentageController.text =
                                  calculatedPercentage.toStringAsFixed(2);
                            }

                            // ✅ Update selectedDiscountType for your existing logic
                            selectedDiscountType = '৳';
                          } else {
                            discountPercentageController.clear();
                          }

                          _isUpdatingFromAmount = false;
                          _recalculatePayment();
                        },
                      ),
                    ),
                  ],
                ),

                // Discount row with % field and amount field

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Payment", style: ts),
                    const SizedBox(width: 24),
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        labelText: 'Payment',
                        controller: paymentAmount,
                        readOnly:
                            true, // user should not edit final payment manually
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Total Amount Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),

                    backgroundColor: Colors.green, // Button background color
                    foregroundColor: Colors.white, // Button text color
                  ),
                  onPressed: () async {
                    ///final api call here ====== >>>>>>
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userIdStr = prefs.getInt('user_id')?.toString();

                    if (userIdStr == null) {
                      debugPrint("User ID is null");
                      return;
                    }

                    /// ✅ Get Selected Customer ID
                    final selectedCustomer =
                        Provider.of<CustomerProvider>(context, listen: false)
                            .selectedCustomer;

                    if (selectedCustomer != null) {
                      debugPrint(
                          'Selected Customer ID: ${selectedCustomer.id}');
                      debugPrint(
                          'Selected Customer Name: ${selectedCustomer.name}');
                    } else {
                      debugPrint('No customer selected.');
                    }

                    String receivedToValue =
                        getReceivedToValue(selectedReceivedTo!);

                    debugPrint("Send to API: $receivedToValue");

                    int userId = int.parse(userIdStr);
                    //int customerId = selectedCustomer?.id ??
                    0; // from your selected customer object
                    int voucherPerson = selectedBillPersonData?.id ?? 0;
                    String voucherNumber = billController.text.trim();
                    String voucherDate =
                        DateFormat('yyyy-MM-dd').format(DateTime.now());
                    String voucherTime =
                        DateFormat('HH:mm:ss').format(DateTime.now());

                    ///payment bank or cash
                    String paymentForm =
                        receivedToValue; // adapt this accordingly
                    int accountId = selectedAccountId ?? 0;
                    int paymentTo = selectedCustomer!
                        .id; //selectedAccountId ?? 0; // or payment to id

                    String percent = discountPercentageController
                        .text; // "%", "percent", or "flat", adjust as needed
                    //double totalAmt = double.tryParse(totalAmount.text) ?? 0;
                    double paymentAmt =
                        double.tryParse(paymentAmount.text) ?? 0;
                    double discountAmt =
                        double.tryParse(discountAmount.text) ?? 0;
                    String notes = noteController.text; // from your input

                    // Replace this section in your Save button onPressed method:

                    final customerProvider =
                        Provider.of<CustomerProvider>(context, listen: false);

                    List<VoucherItem> voucherItems = [];

                    // ✅ FIXED: Use paymentVouchers instead of receivedVouchers
                    for (int i = 0;
                        i < customerProvider.paymentVouchers.length;
                        i++) {
                      final PaymentVoucherCustomer invoice =
                          customerProvider.paymentVouchers[i];
                      final TextEditingController? controller =
                          receiptControllers[i];

                      if (controller != null &&
                          controller.text.trim().isNotEmpty) {
                        final double amount =
                            double.tryParse(controller.text.trim()) ?? 0;
                        if (amount > 0) {
                          voucherItems.add(VoucherItem(
                            salesId: invoice.id.toString(),
                            amount: amount.toStringAsFixed(2),
                          ));

                          // ✅ Debug print to verify data
                          debugPrint(
                              'Adding Voucher Item → sales_id: ${invoice.id}, amount: ${amount.toStringAsFixed(2)}');
                        }
                      }
                    }

// ✅ Add validation before API call
                    if (voucherItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please enter payment amounts for at least one invoice."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return; // Don't proceed with API call
                    }

                    final request = PaymentVoucherRequest(
                      userId: userId,
                      customerId: selectedCustomer.id,
                      voucherPerson: voucherPerson,
                      voucherNumber: voucherNumber,
                      voucherDate: voucherDate,
                      voucherTime: voucherTime,
                      paymentForm: paymentForm, // ✅ FIXED paymentForm,
                      accountId: accountId,
                      paymentTo: paymentTo,
                      percent: percent,
                      totalAmount: paymentAmt, //totalAmt,
                      discount: discountAmt,
                      notes: notes,
                      voucherItems: voucherItems,
                    );

                    final provider = Provider.of<PaymentVoucherProvider>(
                        context,
                        listen: false);
                    bool success = await provider.storePaymentVoucher(request);

                    if (success) {
                      // ✅ Clear payment fields
                      receiptControllers
                          .clear(); // Clear all TextEditingControllers

                      // ✅ Clear selected customer in provider
                     customerProvider.clearSelectedCustomer();
                      customerProvider.paymentVouchers
                          .clear(); // Clear the voucher list

                      // ✅ Notify listeners so UI updates
                      customerProvider.notifyListeners();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                                "Successfully, Payment voucher saved successfully!")),
                      );

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentOutList()));
                      // Optionally reset form or navigate
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Failed, to save payment voucher.")),
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
    );
  }
}
