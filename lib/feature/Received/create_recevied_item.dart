import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/Received/model/create_recived_voucher_model.dart';
import 'package:cbook_dt/feature/Received/provider/received_provider.dart';
import 'package:cbook_dt/feature/Received/received_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/bill_voucher_settings/provider/bill_settings_provider.dart';
import 'package:cbook_dt/feature/customer_create/model/received_voucher_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/payment_out/model/bill_person_list_model.dart';
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

class ReceivedCreateItem extends StatefulWidget {
  const ReceivedCreateItem({super.key});

  @override
  State<ReceivedCreateItem> createState() => _ReceivedCreateItemState();
}

class _ReceivedCreateItemState extends State<ReceivedCreateItem> {
  String? selectedReceivedTo;
  String? selectedAccount;

  int? selectedAccountId;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  TextEditingController billNoController = TextEditingController();
  String billNo = '';
  Map<int, TextEditingController> receiptControllers = {};
  TextEditingController totalAmount = TextEditingController();
  TextEditingController discountAmount = TextEditingController();
  TextEditingController paymentAmount = TextEditingController();

  TextEditingController discountPercentage = TextEditingController();
  TextEditingController discountValue = TextEditingController();

  TextEditingController customerNameController = TextEditingController();

  String selectedDiscountType = '%'; // default '%'
  double dueAmount = 0;

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

  //int? selectedIndex; // 🔥 To track which item is expanded

  Set<int> expandedIndexes = {};

  /// Calculate sum of all receipts input
  double get totalReceiptAmount {
    double total = 0;
    for (final c in receiptControllers.values) {
      total += double.tryParse(c.text) ?? 0;
    }
    return total;
  }

  void _recalculatePayment({String? changedField}) {
    double due = totalReceiptAmount; // total receipt entered by user

    if (due <= 0) {
      paymentAmount.text = "0.00";
      totalAmount.text = "0.00";
      return;
    }

    double percent = double.tryParse(discountPercentage.text.trim()) ?? 0;
    double value = double.tryParse(discountValue.text.trim()) ?? 0;

    // Clamp percentage to 0-100
    if (percent > 100) {
      percent = 100;
      discountPercentage.text = "100";
    }
    if (percent < 0) {
      percent = 0;
      discountPercentage.text = "0";
    }

    // Clamp value to 0-due
    if (value > due) {
      value = due;
      discountValue.text = due.toStringAsFixed(2);
    }
    if (value < 0) {
      value = 0;
      discountValue.text = "0";
    }

    // Cross-calculate based on which field was changed
    if (changedField == 'percentage') {
      // User changed percentage, calculate value
      double calculatedValue = (percent / 100) * due;
      discountValue.text = calculatedValue.toStringAsFixed(2);
      value = calculatedValue;
    } else if (changedField == 'value') {
      // User changed value, calculate percentage
      double calculatedPercent = due > 0 ? (value / due) * 100 : 0;
      discountPercentage.text = calculatedPercent.toStringAsFixed(2);
      percent = calculatedPercent;
    }

    // Calculate final payment
    double finalPayment = due - value;
    if (finalPayment < 0) finalPayment = 0;

    setState(() {
      totalAmount.text = due.toStringAsFixed(2); // total before discount
      paymentAmount.text = finalPayment.toStringAsFixed(2);
    });

    debugPrint(
      'Total Receipt: $due, Percent: $percent, Value: $value, '
      'Final Payment: $finalPayment',
    );
  }

  TextEditingController billController = TextEditingController();

  @override
  void initState() {
    super.initState();

    billController.text = "Loading...";
    debugPrint('Bill controller initialized with: ${billController.text}');

    customerNameController.clear();

    Future.microtask(() async {
      // First fetch settings and wait for completion
      await Provider.of<BillSettingsProvider>(context, listen: false)
          .fetchSettings();
      debugPrint('Settings fetched successfully');
      await fetchAndSetBillNumber(context);
    });

    Future.microtask(() async {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr();

      Provider.of<PaymentVoucherProvider>(context, listen: false)
          .fetchBillPersons();
    });
  }

  ///bill number
  Future<void> fetchAndSetBillNumber(BuildContext context) async {
    debugPrint('fetchAndSetBillNumber called');

    final settingsProvider =
        Provider.of<BillSettingsProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Fetch required values from provider (now they should be available)
    final code = settingsProvider.getValue("received_code") ?? "";
    final billNumber = settingsProvider.getValue("received_bill_no") ?? "";
    final withNickName = settingsProvider.getValue("with_nick_name") ?? "0";

    debugPrint(
        'Settings values - code: $code, billNumber: $billNumber, withNickName: $withNickName');

    final url = Uri.parse(
      '${AppUrl.baseurl}app/setting/bill/number'
      '?voucher_type=voucher'
      '&type=receipt'
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
          billController.text = code.isNotEmpty ? "$code-100" : "REC-100";
          debugPrint('Fallback bill set to: ${billController.text}');
        });
      }
    } catch (e) {
      debugPrint('Error fetching bill number: $e');
      if (mounted) {
        setState(() {
          billController.text = code.isNotEmpty ? "$code-100" : "REC-100";
          debugPrint('Fallback bill set to: ${billController.text}');
        });
      }
    }
  }

  ///clear the controller
  void _clearAllControllers() {
    debugPrint('Clearing all controllers...');

    // Clear text controllers
    billNoController.clear();
    totalAmount.clear();
    discountAmount.clear();
    paymentAmount.clear();
    discountPercentage.clear();
    discountValue.clear();
    billController.clear();

    // ✅ Clear customer name controller from SalesController
    // final controllerCustomerName = Provider.of<SalesController>(context, listen: false);
    // controllerCustomerName.customerNameController.clear();

    // Clear receipt controllers map
    receiptControllers.forEach((key, controller) {
      controller.clear();
      controller.dispose(); // Dispose to prevent memory leaks
    });
    receiptControllers.clear();

    // Reset dropdown selections
    selectedReceivedTo = null;
    selectedAccount = null;
    selectedAccountId = null;
    selectedBillPerson = null;
    selectedBillPersonId = null;
    selectedBillPersonData = null;

    // Reset other state variables
    billNo = '';
    dueAmount = 0;
    expandedIndexes.clear();

    debugPrint('All controllers cleared successfully');
  }

// Add this method to your _ReceivedCreateItemState class

  /// Clear all controllers and reset form state

// Override dispose method to clean up controllers when widget is destroyed
  @override
  void dispose() {
    debugPrint('Disposing controllers...');

    // Dispose all text controllers
    billNoController.dispose();
    totalAmount.dispose();
    discountAmount.dispose();
    paymentAmount.dispose();
    discountPercentage.dispose();
    discountValue.dispose();
    billController.dispose();

    // Dispose receipt controllers
    receiptControllers.forEach((key, controller) {
      controller.dispose();
    });
    receiptControllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();

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
              'Received Create',
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
        padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 0),
        child: Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 48,
              color: const Color(0xffdddefa),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Bill No Field

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bill/Invoice no',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          Text(
                            '${billController.text}',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Vertical Divider
                  Container(
                    width: 1,
                    height:
                        40, // you can tweak this to match the height of content
                    color: Colors.black,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),

                  // SizedBox(
                  //   height: 38,
                  //   width: 130,
                  //   child: AddSalesFormfield(
                  //     labelText: "Bill No",
                  //     controller: billController,
                  //     readOnly: true, // Prevent manual editing
                  //   ),
                  // ),

                  //person

                  ///bill date

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: 130,
                          child: InkWell(
                            // onTap: () => controller.pickDate(
                            //     context), // Trigger the date picker
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                //suffixIcon: ,
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ), // Adjust constraints to align icon closely
                                hintText: "Bill Date",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 9,
                                ),
                                // enabledBorder: UnderlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: Colors.grey.shade400, width: 0.5),
                                // ),
                                // focusedBorder: const UnderlineInputBorder(
                                //   borderSide: BorderSide(color: Colors.green),
                                // ),
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
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            ///1 section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 38,
                      width: 150,
                      child: CustomDropdownTwo(
                        hint: '',
                        items: const ['Cash in Hand', 'Bank'],
                        width: double.infinity,
                        height: 30,
                        labelText: 'Receipt To',
                        selectedItem: selectedReceivedTo,
                        onChanged: (value) async {
                          debugPrint('=== Received To Selected: $value ===');

                          // Map label to backend value
                          String? mappedValue;
                          if (value == 'Cash in Hand') {
                            mappedValue = 'cash';
                          } else if (value == 'Bank') {
                            mappedValue = 'bank';
                          }

                          setState(() {
                            selectedReceivedTo =
                                mappedValue; // store mapped value
                            selectedAccount = null; // reset account selection
                          });

                          if (mappedValue == 'cash') {
                            debugPrint('Fetching Cash accounts...');
                            await provider.fetchAccounts('cash');
                          } else if (mappedValue == 'bank') {
                            debugPrint('Fetching Bank accounts...');
                            await provider.fetchAccounts('bank');
                          }

                          debugPrint('cash or bank: $selectedReceivedTo');
                          debugPrint(
                              'Fetched Account Names: ${provider.accountNames}');
                        },
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// Account Dropdown
                    SizedBox(
                      height: 38,
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
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            const Center(
              child: Text(
                "Received From",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),

            const SizedBox(height: 6),

            /// Customer search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AddSalesFormfieldTwo(
                controller: customerNameController,
                customerorSaleslist: "Showing Customer list",
                customerOrSupplierButtonLavel: "",
                color: Colors.grey,
                isForReceivedVoucher: true,
                onTap: () async {
                  // Add your customer selection logic
                },
              ),
            ),

            /// Show customer payable/receivable if selected
            Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                final customerList =
                    customerProvider.customerResponse?.data ?? [];
                final selectedCustomerRecived =
                    customerProvider.selectedCustomerRecived;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customerList.isEmpty) const SizedBox(height: 2),
                    if (customerList.isNotEmpty &&
                        selectedCustomerRecived != null &&
                        selectedCustomerRecived.id != -1) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: customerProvider.receivedVouchers.isEmpty
                            ? const Center(
                                child: Text(
                                  "No received voucher found.",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    customerProvider.receivedVouchers.length,
                                itemBuilder: (context, index) {
                                  final ReceivedVoucherCustomer invoice =
                                      customerProvider.receivedVouchers[index];
                                  final bool isExpanded =
                                      expandedIndexes.contains(index);

                                  final int salesId = invoice.id;

                                  debugPrint(
                                      "Tapped Invoice ID: ${invoice.id}");

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 1),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3)),
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
                                                    const Text('Receipt',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black)),
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
                                                                  horizontal:
                                                                      10),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          final input =
                                                              double.tryParse(
                                                                      value) ??
                                                                  0;
                                                          final due =
                                                              invoice.due;

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
                                                            ScaffoldMessenger
                                                                    .of(context)
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
                                                              .toStringAsFixed(
                                                                  2);

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
                        height: 38,
                        width: 163,
                        child: AddSalesFormfield(
                          labelText: "Amount",
                          readOnly: true,
                          controller: totalAmount,
                          onChanged: (value) {
                            debugPrint("recived value ${totalAmount.text}");
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Discount", style: ts),
                      const SizedBox(width: 10),

                      // Percentage input
                      SizedBox(
                        height: 38,
                        width: 78,
                        child: AddSalesFormfield(
                          keyboardType: TextInputType.number,
                          labelText: '%',
                          controller: discountPercentage,
                          onChanged: (value) {
                            _recalculatePayment(changedField: 'percentage');
                          },
                        ),
                      ),

                      const SizedBox(width: 4),

                      // Discount value input
                      SizedBox(
                        height: 38,
                        width: 78,
                        child: AddSalesFormfield(
                          keyboardType: TextInputType.number,
                          labelText: 'Value',
                          controller: discountValue,
                          onChanged: (value) {
                            _recalculatePayment(changedField: 'value');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Received
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Received", style: ts),
                      const SizedBox(width: 24),
                      SizedBox(
                        height: 38,
                        width: 163,
                        child: AddSalesFormfield(
                          labelText: "Received",
                          controller: paymentAmount,
                          readOnly: true,
                          onChanged: (value) {},
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
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? userIdStr = prefs.getInt('user_id')?.toString();

                      if (userIdStr == null) {
                        debugPrint("User ID is null");
                        return;
                      }

                      final selectedCustomer =
                          Provider.of<CustomerProvider>(context, listen: false)
                              .selectedCustomerRecived;

                      if (selectedCustomer == null) {
                        debugPrint('No customer selected.');
                        return;
                      }

                      int userId = int.parse(userIdStr);
                      int customerId = selectedCustomer.id;
                      int voucherPerson = selectedBillPersonData?.id ?? 0;
                      String billNO = billController.text;
                      String voucherDate =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      String voucherTime =
                          DateFormat('HH:mm:ss').format(DateTime.now());
                      String receivedTo =
                          (selectedReceivedTo ?? "cash").toLowerCase();
                      int accountId = selectedAccountId ?? 0;
                      int receivedFrom = customerId;
                      String percent = discountPercentage.text;
                      //double totalAmt = double.tryParse(totalAmount.text) ?? 0;
                      double paymentAmt =
                          double.tryParse(paymentAmount.text) ?? 0;
                      String discountAmt = discountValue.text;
                      String notes = 'notes';

                      debugPrint('voucher number  ${billNO}');
                      debugPrint('discount percentance  ${percent}');
                      debugPrint('discount amount  ${discountAmt}');

                      final customerProvider =
                          Provider.of<CustomerProvider>(context, listen: false);
                      List<ReceivedVoucherItem> voucherItems = [];

                      for (int i = 0;
                          i < customerProvider.receivedVouchers.length;
                          i++) {
                        final ReceivedVoucherCustomer invoice =
                            customerProvider.receivedVouchers[i];
                        final TextEditingController? controller =
                            receiptControllers[i];

                        if (controller != null &&
                            controller.text.trim().isNotEmpty) {
                          final double amount =
                              double.tryParse(controller.text.trim()) ?? 0;
                          if (amount > 0) {
                            voucherItems.add(ReceivedVoucherItem(
                              salesId: invoice.id.toString(),
                              amount: amount.toStringAsFixed(2),
                            ));
                          }
                        }
                      }

                      final request = ReceivedVoucherRequest(
                        userId: userId,
                        custoerID: customerId,
                        voucherPerson: voucherPerson,
                        voucherNumber: billNO,
                        voucherDate: voucherDate,
                        voucherTime: voucherTime,
                        receivedTo: receivedTo,
                        accountId: accountId,
                        receivedFrom: receivedFrom,
                        percent: percent,
                        discount: discountAmt,
                        totalAmount: paymentAmt,
                        notes: notes,
                        voucherItems: voucherItems,
                      );

                      final provider = Provider.of<ReceiveVoucherProvider>(
                          context,
                          listen: false);
                      bool success =
                          await provider.storeReceivedVoucher(request);

                      if (success) {
                        _clearAllControllers();

                        customerNameController.clear();

                        // ✅ Clear the selected customer
                        Provider.of<CustomerProvider>(context, listen: false)
                            .clearSelectedCustomerRecived();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: AppColors.primaryColor,
                              content: const Text(
                                "Received voucher saved successfully!",
                                style: TextStyle(color: Colors.white),
                              )),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ReceivedList()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Failed to save received voucher.")),
                        );
                      }
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 50,
            )
          ]),
        ),
      ),
    );
  }
}
