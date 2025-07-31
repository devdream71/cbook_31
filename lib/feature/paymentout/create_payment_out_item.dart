import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/customer_create/model/payment_voicer_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/model/create_payment_out.dart';
import 'package:cbook_dt/feature/paymentout/payment_out_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
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

  String? selectedReceivedTo;
  String? selectedAccount;

  //String? selectedReceivedTo;     // e.g. 'Cash in Hand'
  String? internalReceivedTo;

  String getReceivedToValue(String label) {
    if (label == 'Cash in Hand') return 'cash';
    if (label == 'Bank') return 'bank';
    return ''; // fallback if needed
  }

  int? selectedAccountId;

  DateTime selectedStartDate = DateTime.now();
  // Default to current date
  DateTime selectedEndDate = DateTime.now();
  // Default to current date
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

  Map<int, TextEditingController> receiptControllers = {};

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel?
      selectedBillPersonData; // ✅ Store the selected object globally

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

  void prepareIncomeItems(IncomeProvider provider, String selectedAccountId) {
    // Convert receiptItems to required JSON structure
    final List<Map<String, dynamic>> incomeItems =
        provider.receiptItems.map((item) {
      return {
        "account_id": selectedAccountId,
        "narration": item.note,
        "amount": item.amount.toString(),
      };
    }).toList();

    final Map<String, dynamic> finalPayload = {
      "income_items": incomeItems,
    };

    // Print JSON string in console
    debugPrint('Final JSON Payload: $finalPayload');
  }

  Set<int> expandedIndexes = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr();

      Provider.of<PaymentVoucherProvider>(context, listen: false)
          .fetchBillPersons();

      await fetchAndSetBillNumber();
    });

    // Future.microtask(() =>
    //     Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    // Future.microtask(() =>
    //     Provider.of<PaymentVoucherProvider>(context, listen: false)
    //         .fetchBillPersons());
  }

  // Updated fetchAndSetBillNumber with more debugging:
  // Future<void> fetchAndSetBillNumber() async {
  //   debugPrint('fetchAndSetBillNumber called');

  //   final url = Uri.parse(
  //     'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=voucher&type=payment-out&code=PAY&bill_number=100&with_nick_name=1',
  //   );

  //   debugPrint('API URL: $url');

  //   try {
  //     debugPrint('Making API call...');
  //     final response = await http.get(url);
  //     debugPrint('API Response Status: ${response.statusCode}');
  //     debugPrint('API Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       debugPrint('Parsed data: $data');

  //       if (data['success'] == true && data['data'] != null) {
  //         String billFromApi = data['data'].toString(); // Ensure it's a string
  //         debugPrint('Bill from API: $billFromApi');

  //         //String newBill = _incrementBillNumber(billFromApi);

  //         String newBill = billFromApi;

  //         debugPrint('New bill after increment: $newBill');

  //         // Update the controller and trigger UI rebuild
  //         if (mounted) {
  //           setState(() {
  //             billController.text = newBill;
  //             debugPrint('Bill controller updated to: ${billController.text}');
  //           });
  //         }
  //       } else {
  //         debugPrint('API success false or data null');
  //         // Handle API error
  //         if (mounted) {
  //           setState(() {
  //             billController.text = "PAY-100"; // Default fallback
  //             debugPrint('Set fallback bill: ${billController.text}');
  //           });
  //         }
  //       }
  //     } else {
  //       debugPrint('Failed to fetch bill number: ${response.statusCode}');
  //       // Set fallback bill number
  //       if (mounted) {
  //         setState(() {
  //           billController.text = "PAY-100";
  //           debugPrint(
  //               'Set fallback bill due to status code: ${billController.text}');
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching bill number: $e');
  //     // Set fallback bill number
  //     if (mounted) {
  //       setState(() {
  //         billController.text = "PAY-100";
  //         debugPrint('Set fallback bill due to exception: ${billController.text}');
  //       });
  //     }
  //   }
  // }

  ///updated bill nunber json respoonse
  Future<void> fetchAndSetBillNumber() async {
    debugPrint('fetchAndSetBillNumber called');

    final url = Uri.parse(
      'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=voucher&type=payment&code=PAY&bill_number=100&with_nick_name=1',
    );

    try {
      debugPrint('Making API call...');
      final response = await http.get(url);
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Parsed data: $data');

        if (data['success'] == true && data['data'] != null) {
          final billFromApi =
              data['data']['bill_number']?.toString().trim() ?? "";

          debugPrint('Bill from API: $billFromApi');

          // Optional: extract only number from "PAY-100"
          final billOnlyNumber = billFromApi;

          if (mounted) {
            setState(() {
              billController.text = billOnlyNumber;
              debugPrint('Bill controller updated to: ${billController.text}');
            });
          }
        } else {
          debugPrint('API success false or data missing');
          _setFallback();
        }
      } else {
        debugPrint('Failed to fetch bill number: ${response.statusCode}');
        _setFallback();
      }
    } catch (e) {
      debugPrint('Error fetching bill number: $e');
      _setFallback();
    }
  }

  void _setFallback() {
    if (mounted) {
      setState(() {
        billController.text = "PAY-100"; // or any default you want
        debugPrint('Fallback bill set: ${billController.text}');
      });
    }
  }

  TextEditingController billNoController = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();
  String billNo = '';

  TextEditingController discountAmount = TextEditingController();
  TextEditingController paymentAmount = TextEditingController();

  //String? selectedDiscountType;

  String selectedDiscountType = '%'; // default '%'
  double dueAmount =
      0; // You should assign this when customer selected or invoice loaded

  /// Calculate sum of all receipts input
  double get totalReceiptAmount {
    double total = 0;
    for (final c in receiptControllers.values) {
      total += double.tryParse(c.text) ?? 0;
    }
    return total;
  }

  /// Called when discount or receipt amounts change
  void _recalculatePayment() {
    double due = totalReceiptAmount; // total receipt entered by user

    final discountText = discountAmount.text.trim();
    double discountValue = double.tryParse(discountText) ?? 0;

    if (due <= 0) {
      paymentAmount.text = "0.00";
      totalAmount.text = "0.00";
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
    final providerExpense = Provider.of<ExpenseProvider>(context, listen: true);

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
              'Payment out Create',
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ///1 section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                        // setState(() {
                        //   selectedReceivedTo = value;
                        //   selectedAccount = null; // reset account selection
                        // });

                        // if (value == 'Cash in Hand') {
                        //   debugPrint('Fetching Cash accounts...');
                        //   await provider.fetchAccounts('cash');
                        // } else if (value == 'Bank') {
                        //   debugPrint('Fetching Bank accounts...');
                        //   await provider.fetchAccounts('bank');
                        // }

                        // debugPrint(
                        //     'Fetched Account Names: ${provider.accountNames}');
                        // debugPrint ("selectedReceivedTo ===> ${selectedReceivedTo}<======");
                        //
                        //
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

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Consumer<PaymentVoucherProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 30,
                          width: 130,
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
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

                                    debugPrint('Selected Bill Person Details:');
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

                  ///bill no, bill person
                  // SizedBox(
                  //   height: 30,
                  //   width: 130,
                  //   child: AddSalesFormfield(
                  //     labelText: "Voucher NO",
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

          ///2 section
          // InkWell(
          //   onTap: () async {},
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: colorScheme.primary,
          //       borderRadius: BorderRadius.circular(3),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.2),
          //           blurRadius: 5,
          //           offset: const Offset(0, 3),
          //         ),
          //       ],
          //     ),
          //     child: const Padding(
          //       padding: EdgeInsets.all(4.0),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             "Payment To",
          //             style: TextStyle(color: Colors.white, fontSize: 14),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(height: 6),

          /// Customer search field
          AddSalesFormfieldTwo(
            controller: controller.customerNameController,
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customerList.isEmpty) const SizedBox(height: 2),
                  if (customerList.isNotEmpty &&
                      selectedCustomer != null &&
                      selectedCustomer.id != -1) ...[
                    Row(
                      children: [
                        Text(
                          "${selectedCustomer.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: selectedCustomer.type == 'customer'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            "৳ ${selectedCustomer.due.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: CustomDropdownTwo(
                        hint: '',
                        items: const ['%', '৳'],
                        width: double.infinity,
                        height: 30,
                        labelText: selectedDiscountType,
                        selectedItem: selectedDiscountType,
                        onChanged: (value) {
                          setState(() {
                            selectedDiscountType = value ?? '%';
                            _recalculatePayment();
                          });
                          debugPrint(
                              'Discount type selected: $selectedDiscountType');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    ///discount amount
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: AddSalesFormfield(
                        labelText: "Amount",
                        controller: discountAmount,
                        onChanged: (value) {
                          _recalculatePayment();
                        },
                      ),
                    ),
                  ],
                ),

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

                    print("Send to API: $receivedToValue");

                    int userId = int.parse(userIdStr);
                    int customerId = selectedCustomer?.id ??
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
                    int paymentTo = selectedAccountId ?? 0; // or payment to id
                    String percent =
                        selectedDiscountType; // "%", "percent", or "flat", adjust as needed
                    double totalAmt = double.tryParse(totalAmount.text) ?? 0;
                    double paymentAmt =
                        double.tryParse(paymentAmount.text) ?? 0;
                    double discountAmt =
                        double.tryParse(discountAmount.text) ?? 0;
                    String notes = 'notes'; // from your input

                    // List<VoucherItem> voucherItems = [
                    //   VoucherItem(
                    //       salesId: "57", amount: totalAmt.toStringAsFixed(2)),
                    //   // you can dynamically add items here from your form
                    // ];

                    final customerProvider =
                        Provider.of<CustomerProvider>(context, listen: false);
                    List<VoucherItem> voucherItems = [];

                    for (int i = 0;
                        i < customerProvider.receivedVouchers.length;
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
                        }
                      }
                    }

                    final request = PaymentVoucherRequest(
                      userId: userId,
                      customerId: customerId,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Payment voucher saved successfully!")),
                      );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentOutList()));
                      // Optionally reset form or navigate
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Failed to save payment voucher.")),
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
