import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/Received/model/create_recived_voucher.dart';
import 'package:cbook_dt/feature/Received/provider/received_provider.dart';
import 'package:cbook_dt/feature/Received/received_list.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/customer_create/model/received_voucher_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceviedEdit extends StatefulWidget {
  final String receviedId;
  const ReceviedEdit({super.key, required this.receviedId});

  @override
  State<ReceviedEdit> createState() => _ReceviedEditState();
}

class _ReceviedEditState extends State<ReceviedEdit> {
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String? selectedDropdownValue;
  String? selectedReceivedTo;
  String? selectedAccount;
  int? selectedAccountId;
  TextEditingController billNoController = TextEditingController();

  String billNo = '';
  String billDate = '';
  Map<int, TextEditingController> receiptControllers = {};

  late TextEditingController voucherNumberController;
  late TextEditingController totalAmount;
  late TextEditingController discountAmount;
  TextEditingController paymentAmount = TextEditingController();
  String selectedDiscountType = '%'; // default '%'
  double dueAmount = 0;
  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;
  Set<int> expandedIndexes = {};

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

  // Updated initState method with correct API data mapping
  @override
  void initState() {
    super.initState();

    voucherNumberController = TextEditingController();
    totalAmount = TextEditingController();
    discountAmount = TextEditingController();

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    Future.microtask(() async {
      final provider =
          Provider.of<ReceiveVoucherProvider>(context, listen: false);
      final data = await provider.fetchReceiveVoucherById(widget.receviedId);

      if (data != null) {
        setState(() {
          // ✅ Correct field mappings based on API response
          voucherNumberController.text = data['voucher_number'] ?? '';

          // ✅ Map received_to correctly (API returns 'cash' or 'bank')
          selectedReceivedTo =
              data['received_to'] == 'cash' ? 'Cash in Hand' : 'Bank';

          // ✅ bill_person_id mapping
          selectedBillPersonId = data['bill_person_id'];

          // ✅ account_type mapping
          selectedAccountId = data['account_type'];

          // ✅ Handle null discount_type from API
          selectedDiscountType = data['discount_type'] ?? '%';

          // ✅ Use discount_amount from API
          discountAmount.text = (data['discount_amount'] ?? 0).toString();

          // ✅ Use total_amount from API
          totalAmount.text = (data['total_amount'] ?? 0).toString();

          // ✅ Date mapping
          selectedStartDate =
              DateTime.tryParse(data['voucher_date']) ?? DateTime.now();
          selectedEndDate =
              DateTime.tryParse(data['voucher_date']) ?? DateTime.now();

          // ✅ Set customer_id if available
          if (data['customer_id'] != null) {
            // You'll need to set the selected customer based on customer_id
            _setSelectedCustomer(data['customer_id']);
          }

          // ✅ Fill voucher details list - CORRECTED spelling
          if (data['voucher_detaiuls'] is List) {
            final List details = data['voucher_detaiuls'];
            receiptControllers.clear(); // Clear existing controllers

            for (int i = 0; i < details.length; i++) {
              final item = details[i];
              final controller =
                  TextEditingController(text: (item['amount'] ?? 0).toString());
              receiptControllers[i] = controller;

              // Add listener to recalculate when amount changes
              controller.addListener(() {
                _recalculatePayment();
              });
            }
          }

          // ✅ Load account dropdown based on received_to
          _loadAccountDropdown();

          //await _loadAccountDropdown();

          // ✅ Set bill person if ID is available
          _setBillPerson();

          _recalculatePayment();

          debugPrint('Received To: $selectedReceivedTo');
          debugPrint('Bill Person ID: $selectedBillPersonId');
          debugPrint('Account ID: $selectedAccountId');
          debugPrint('Customer ID: ${data['customer_id']}');
        });
      }
    });
  }

//Helper method to load account dropdown based on received_to
  void _loadAccountDropdown() async {
    final provider = Provider.of<IncomeProvider>(context, listen: false);

    if (selectedReceivedTo == 'Cash in Hand') {
      await provider.fetchAccounts('cash');
    } else if (selectedReceivedTo == 'Bank') {
      await provider.fetchAccounts('bank');
    }

    // Set selected account after loading
    if (selectedAccountId != null && provider.accountModel != null) {
      final account = provider.accountModel!.data.firstWhere(
        (acc) => acc.id == selectedAccountId,
        orElse: () => provider.accountModel!.data.first,
      );
      setState(() {
        selectedAccount = account.accountName;
      });
    }
  }

// Helper method to set bill person
  void _setBillPerson() {
    if (selectedBillPersonId != null) {
      final provider =
          Provider.of<PaymentVoucherProvider>(context, listen: false);

      // You might need to wait for bill persons to load first
      Future.delayed(Duration(milliseconds: 500), () {
        if (provider.billPersons.isNotEmpty) {
          try {
            final billPerson = provider.billPersons.firstWhere(
              (person) => person.id == selectedBillPersonId,
            );
            setState(() {
              selectedBillPerson = billPerson.name;
              selectedBillPersonData = billPerson;
            });
          } catch (e) {
            debugPrint('Bill person not found with ID: $selectedBillPersonId');
          }
        }
      });
    }
  }

// Helper method to set selected customer
  void _setSelectedCustomer(int customerId) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    //Wait for customers to load then set the selected one
    Future.delayed(Duration(milliseconds: 500), () {
      if (customerProvider.customerResponse?.data != null) {
        final customer = customerProvider.findCustomerById(customerId);

        if (customer != null) {
          // Set the customer in the provider
          customerProvider.setSelectedCustomerRecived(customer);

          // Update the controller text
          final controller =
              Provider.of<SalesController>(context, listen: false);
          controller.customerNameController.text = customer.name;

          debugPrint('Successfully set customer: ${customer.name}');
        } else {
          debugPrint('Customer not found with ID: $customerId');
        }
      }
    });
  }

// Updated dispose method to dispose all controllers
  @override
  void dispose() {
    voucherNumberController.dispose();
    totalAmount.dispose();
    discountAmount.dispose();

    // Dispose all receipt controllers
    for (final controller in receiptControllers.values) {
      controller.dispose();
    }
    receiptControllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("recived voucer id ====${widget.receviedId}");
    print("voucher number ====${voucherNumberController.text}");
    print("total amount ====${totalAmount.text}");
    print("discount amount ====${discountAmount.text}");

    final controller = context.watch<SalesController>();
    final provider = Provider.of<IncomeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

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
              'Recevied Update',
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

          ///1 section, receipt to, a/c.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //receipt to
                  SizedBox(
                    height: 30,
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

              ////righ side data
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ///bill person
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

                  ///bill no,
                  SizedBox(
                    height: 30,
                    width: 130,
                    child: AddSalesFormfield(
                      labelText: "Bill No",
                      controller: voucherNumberController,

                      onChanged: (value) {
                        billNo = value;
                      }, // Match cursor height to text size
                    ),
                  ),

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

          ///customer show
          InkWell(
            onTap: () async {},
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Received From",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// Customer search field
          AddSalesFormfieldTwo(
            controller: controller.customerNameController,
            customerorSaleslist: "Showing Customer list",
            customerOrSupplierButtonLavel: "",
            color: Colors.grey,
            isForReceivedVoucher: true,
            onTap: () async {
              // Add your customer selection logic
            },
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
                    Row(
                      children: [
                        Text(
                          "${selectedCustomerRecived.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: selectedCustomerRecived.type == 'customer'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            "৳ ${selectedCustomerRecived.due.toStringAsFixed(2)}",
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

                                print("Tapped Invoice ID: ${invoice.id}");

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
                                                  const Text('Receipt',
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

          ////down bottom save option
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
                      height: 30,
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
                        items: ['%', '৳'],
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
                const SizedBox(height: 4),

                // Received
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Receive", style: ts),
                    const SizedBox(width: 24),
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        labelText: "Receive",
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

                    // ⚠️ You need to pass the voucher ID that you want to update
                    // This should come from your screen/widget parameters or state
                    String voucherId = widget
                        .receviedId; // Replace this with actual voucher ID

                    int userId = int.parse(userIdStr);
                    int customerId = selectedCustomer.id;
                    int voucherPerson = selectedBillPersonData?.id ?? 0;
                    String voucherNumber = billNoController.text.trim();
                    String voucherDate =
                        DateFormat('yyyy-MM-dd').format(DateTime.now());
                    String voucherTime =
                        DateFormat('HH:mm:ss').format(DateTime.now());
                    String receivedTo =
                        (selectedReceivedTo ?? "cash").toLowerCase();
                    int accountId = selectedAccountId ?? 0;
                    int receivedFrom = customerId;
                    String percent = selectedDiscountType;
                    double totalAmt = double.tryParse(totalAmount.text) ?? 0;
                    double paymentAmt =
                        double.tryParse(paymentAmount.text) ?? 0;
                    double discountAmt =
                        double.tryParse(discountAmount.text) ?? 0;
                    String notes = 'notes';

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
                      voucherNumber: voucherNumber,
                      voucherDate: voucherDate,
                      voucherTime: voucherTime,
                      receivedTo: receivedTo,
                      accountId: accountId,
                      receivedFrom: receivedFrom,
                      percent: percent,
                      totalAmount: paymentAmt,
                      discount: discountAmt,
                      notes: notes,
                      voucherItems: voucherItems,
                    );

                    final provider = Provider.of<ReceiveVoucherProvider>(
                        context,
                        listen: false);

                    // 🔄 Call the update method instead of store
                    bool success = await provider.updateReceivedVoucher(
                        voucherId, request);

                    if (success) {
                      // ✅ Clear the selected customer
                      Provider.of<CustomerProvider>(context, listen: false)
                          .clearSelectedCustomerRecived();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "successfully!, Received voucher updated.",
                              style: TextStyle(color: Colors.green),
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
                                Text("Failed to update received voucher.")),
                      );
                    }
                  },
                  child: const Text("Update"),
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
