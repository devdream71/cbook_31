import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expence_item.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_popup.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_paid_form_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseEdit extends StatefulWidget {
  final String expenseId;
  const ExpenseEdit({super.key, required this.expenseId});

  @override
  State<ExpenseEdit> createState() => _ExpenseEditState();
}

class _ExpenseEditState extends State<ExpenseEdit> {
  
  String? selectedReceivedTo;
  String? selectedAccount;
  int? selectedAccountId;
  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;
  TextEditingController billNoController = TextEditingController();
  late TextEditingController voucherNumberController;
  String billNo = '';
  String billDate = '';

  @override
  void initState() {
    super.initState();

    voucherNumberController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ///expense provider
      final providerExpense =
          Provider.of<ExpenseProvider>(context, listen: false);

      ///income provider
      final provider =
          Provider.of<IncomeProvider>(context, listen: false); // 👈 Add this

      /// ✅ First fetch Paid Form List
      await providerExpense.fetchPaidFormList();

      /// ✅ Then fetch Edit Expense
      await providerExpense.fetchEditExpense(widget.expenseId);

      ///fetch bill person
      Future.microtask(() =>
          Provider.of<PaymentVoucherProvider>(context, listen: false)
              .fetchBillPersons());

      final billPersonList =
          Provider.of<PaymentVoucherProvider>(context, listen: false)
              .billPersons;

      int billPersonIdFromApi =
          providerExpense.editExpenseData?.billPersonId ?? 0; //billPersonId

      final matchingBillPerson = billPersonList.firstWhere(
        (person) => person.id == billPersonIdFromApi,
        orElse: () => billPersonList.first,
      );

      selectedBillPerson = matchingBillPerson.name;
      selectedBillPersonData = matchingBillPerson;
      selectedBillPersonId = matchingBillPerson.id;

      debugPrint('✅ Bill Person Preselected: $selectedBillPerson');

      voucherNumberController.text =
          providerExpense.editExpenseData?.voucherNumber ?? '';

      billDate = providerExpense.editExpenseData?.voucherDate ?? '';

      /// Paid to mapping
      String? paidToApi = providerExpense.editExpenseData?.paidTo;
      if (paidToApi == 'cash') {
        selectedReceivedTo = 'Cash in Hand';
        await provider.fetchAccounts('cash'); // Fetch related accounts
      } else if (paidToApi == 'bank') {
        selectedReceivedTo = 'Bank';
        await provider.fetchAccounts('bank'); // Fetch related accounts
      }

      /// ✅ Preselect Account Name based on accountId
      int accountIdFromApi = providerExpense.editExpenseData?.accountId ?? 0;

      if (provider.accountModel != null) {
        final matchingAccount = provider.accountModel!.data.firstWhere(
          (account) => account.id == accountIdFromApi,
          orElse: () => provider
              .accountModel!.data.first, // fallback to first item if not found
        );

        selectedAccount = matchingAccount.accountName;
        selectedAccountId = matchingAccount.id;

        debugPrint('Selected Account from API: $selectedAccount');
      }
      setState(() {});
    });
  }

  void resetForm() {
    setState(() {
      // Dropdowns and selections
      selectedReceivedTo = null;
      selectedAccount = null;
      selectedAccountId = null;

      selectedBillPerson = null;
      selectedBillPersonId = null;
      selectedBillPersonData = null;

      // Text input
      billNoController.clear();
      billNo = '';

      // Date
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      Provider.of<SalesController>(context, listen: false).formattedDate2 =
          formattedDate;

      // Clear added items
      Provider.of<ExpenseProvider>(context, listen: false).clearReceiptItems();
    });
  }

  @override
  void dispose() {
    voucherNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();

    final provider = context.watch<IncomeProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    final providerExpense = Provider.of<ExpenseProvider>(context, listen: true);

    TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

    // List of forms with metadata

    // ✅ Show loading indicator while data is fetching

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
              'Expence Update',
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

          const SizedBox(
            height: 6,
          ),

          if (providerExpense.editExpenseData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///paid to
                          SizedBox(
                            height: 30,
                            width: 150,
                            child: CustomDropdownTwo(
                              hint: '',
                              items: const ['Cash in Hand', 'Bank'],
                              width: double.infinity,
                              height: 30,
                              labelText: 'Paid To',
                              selectedItem: selectedReceivedTo,
                              onChanged: (value) async {
                                debugPrint(
                                    '=== Received To Selected: $value ===');

                                setState(() {
                                  selectedReceivedTo = value;
                                  selectedAccount =
                                      null; // reset account selection
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
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CustomDropdownTwo(
                                    hint: '',
                                    items: provider.accountNames,
                                    width: double.infinity,
                                    height: 30,
                                    labelText: 'Account',
                                    selectedItem: selectedAccount,
                                    onChanged: (value) {
                                      print('=== Account Selected: $value ===');
                                      setState(() {
                                        selectedAccount = value;
                                      });

                                      if (provider.accountModel != null) {
                                        final selectedAccountData = provider
                                            .accountModel!.data
                                            .firstWhere((account) =>
                                                account.accountName == value);

                                        selectedAccountId =
                                            selectedAccountData.id;

                                        debugPrint(
                                            '=== Account Selected: $value ===');
                                        if (selectedAccountId != null) {
                                          debugPrint(
                                              'Selected Account ID: $selectedAccountId');
                                        }

                                        debugPrint('Selected Account Details:');
                                        debugPrint(
                                            '- ID: ${selectedAccountData.id}');
                                        debugPrint(
                                            '- Name: ${selectedAccountData.accountName}');
                                        debugPrint(
                                            '- Type: $selectedReceivedTo');
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
                                              selectedBillPersonData = provider
                                                  .billPersons
                                                  .firstWhere(
                                                (person) =>
                                                    person.name == value,
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

                          ///bill no, bill person
                          SizedBox(
                            height: 30,
                            width: 130,
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              controller: voucherNumberController,
                              cursorHeight: 12,
                              onChanged: (value) {
                                billNo = value;
                              }, // Match cursor height to text size
                              decoration: InputDecoration(
                                isDense: true, // Ensures the field is compact
                                contentPadding: EdgeInsets
                                    .zero, // Removes unnecessary padding
                                hintText: "Bill no",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
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
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // Example: Format the date if needed
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

                                  setState(() {
                                    billDate =
                                        formattedDate; // Update the selected date
                                  });
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
                                  ), // Adjust constraints to align icon closely
                                  hintText: "Bill Date",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 9,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 0.5),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                child: Text(
                                  billDate.isNotEmpty
                                      ? billDate
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
                ],
              ),
            ),

          const SizedBox(
            height: 8,
          ),

          ///expense item list.
          if (providerExpense.receiptItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  providerExpense.receiptItems.asMap().entries.map((entry) {
                int index = entry.key + 1;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      showExpenseUpdateDialog(context, providerExpense, item);
                    },
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
                          Text(
                            '$index.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerExpense.getAccountNameById(item
                                      .purchaseId), // ✅ show account_name instead of ID
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 1),
                                Text(
                                  (item.note ?? ''),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
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
                                  child: Icon(Icons.close, size: 20),
                                ),
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                    context: context,
                                    onConfirm: () {
                                      setState(() {
                                        providerExpense.receiptItems
                                            .remove(item);
                                        providerExpense.notifyListeners();
                                      });
                                    },
                                  );

                                  // providerExpense.receiptItems.remove(item);
                                  // providerExpense.notifyListeners();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 6),

          ///add new expense item & 2 section
          InkWell(
            onTap: () async {
              await provider
                  .fetchReceiptFromList(); // 🔥 Fetch API before showing dialog

              final expenseProvider =
                  Provider.of<ExpenseProvider>(context, listen: false);
              await expenseProvider.fetchPaidFormList();
              showExpenseCreateDialog(context, expenseProvider);
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
                      "Paid From",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          ///expense update data.
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
                      providerExpense.receiptItems.fold<double>(
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
                    String? userId = prefs.getInt('user_id')?.toString();

                    if (userId == null) {
                      debugPrint("User ID is null");
                      return;
                    }

                    final invoiceNo = voucherNumberController.text.trim();
                    //final invoiceNo = billNoController.text.trim();
                    if (invoiceNo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Expense No cannot be empty')),
                      );
                      return;
                    }

                    final date = billDate;

                    final paidTo =
                        (selectedReceivedTo ?? '').toLowerCase().trim() ==
                                'cash in hand'
                            ? 'cash'
                            : 'bank';
                    //final account = selectedAccountId.toString();
                    final String account = providerExpense
                        .receiptItems.first.purchaseId
                        .toString(); // ✔️ Use correct account id

                    final expenseId = widget.expenseId;

                    const notes = 'text';
                    const status = 1;
                    //final expenseId = "59"; // Pass the correct expense ID

                    final totalAmount =
                        providerExpense.receiptItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum + (double.tryParse(item.amount.toString()) ?? 0),
                    );

                    final List<ExpenseItemPopUp> expenseItems =
                        providerExpense.receiptItems.map((item) {
                      return ExpenseItemPopUp(
                        // accountId: providerExpense.selectedAccountForUpdate?.id
                        //         .toString() ??
                        //     '',

                        // narration: item.note,

                        //accountId: item.purchaseId.toString(),
                        itemAccountId: item.purchaseId.toString(),
                        narration: item.note ?? '',
                        amount: item.amount.toString(),
                      );
                    }).toList();

                    debugPrint('Sending Data:');
                    debugPrint('User ID: $userId');
                    debugPrint('Expense No: $invoiceNo');
                    print("Selected date: $billDate");
                    debugPrint('Paid To: $paidTo');
                    debugPrint('Account: $account');
                    debugPrint('Total Amount: $totalAmount');
                    debugPrint('Notes: $notes');
                    debugPrint('Status: $status');
                    debugPrint(
                        'Expense Items: ${expenseItems.map((e) => e.toJson()).toList()}');

                    bool success = await providerExpense.updateExpense(
                        expenseId: expenseId,
                        userId: userId,
                        invoiceNo: invoiceNo,
                        date: date,
                        paidTo: paidTo,
                        account: account,
                        totalAmount: totalAmount,
                        notes: notes,
                        status: status,
                        expenseItems: expenseItems,
                        billPersonId: selectedBillPersonData!.id);

                    if (success) {
                      providerExpense.receiptItems.clear();
                      providerExpense.notifyListeners();

                      await providerExpense.fetchExpenseList();

                      resetForm();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Expanse()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update expense.')),
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

  ////expense item create=====>
  ///
  void showExpenseCreateDialog(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    await provider.fetchPaidFormList();

    // ✅ Move variables OUTSIDE StatefulBuilder
    TextEditingController amountController = TextEditingController();
    TextEditingController noteController = TextEditingController();
    String? selectedPaidTo;
    PaidFormData? selectedPaidForm;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                        children: [
                          const SizedBox(width: 30),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text(
                                "Paid To",
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.grey.shade100,
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 30,
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomDropdownTwo(
                              hint: '',
                              items: provider.paidFormList
                                  .map((e) => e.accountName)
                                  .toList(),
                              width: double.infinity,
                              height: 30,
                              labelText: 'Paid To',
                              selectedItem: selectedPaidTo,
                              onChanged: (selectedItem) {
                                debugPrint('Selected Paid To: $selectedItem');

                                final matchedAccount = provider.paidFormList
                                    .firstWhere((element) =>
                                        element.accountName == selectedItem);

                                setState(() {
                                  selectedPaidTo = selectedItem;
                                  selectedPaidForm =
                                      matchedAccount; // ✅ Track object correctly
                                  provider.selectedAccountForUpdate =
                                      matchedAccount;
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
                        //   onPressed: () {},
                        //   child: const Text('Add & New'),
                        // ),
                        TextButton(
                          onPressed: () {
                            if (selectedPaidForm != null &&
                                amountController.text.isNotEmpty) {
                              provider.addReceiptItem(
                                ExpenseItem(
                                  purchaseId: selectedPaidForm!.id,
                                  receiptFrom: selectedPaidTo!,
                                  note: noteController.text,
                                  amount:
                                      double.tryParse(amountController.text) ??
                                          0.0,
                                ),
                              );
                              amountController.clear();
                              noteController.clear();
                              Navigator.of(context).pop();
                            } else {
                              // ✅ Optional: Show warning if not selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select Paid To'),
                                ),
                              );
                            }
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

  ////expenseItem update

  void showExpenseUpdateDialog(
    BuildContext context,
    ExpenseProvider provider,
    ExpenseItem item, // ✅ Pass the selected item
  ) async {
    await provider
        .fetchPaidFormList(); // ✅ Fetch API data before showing dialog

    TextEditingController amountController =
        TextEditingController(text: item.amount.toString());
    TextEditingController noteController =
        TextEditingController(text: item.note);
    //String? selectedPaidTo = item.purchaseId.toString(); // ✅ Preselect existing item value

    /// ✅ Preselect account_name instead of ID
    String? selectedPaidTo = provider.getAccountNameById(item.purchaseId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                        children: [
                          const SizedBox(width: 30),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text(
                                "Update Paid Form",
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.grey.shade100,
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 30,
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomDropdownTwo(
                              hint: '',
                              items: provider.paidFormList
                                  .map((e) => e.accountName)
                                  .toList(),
                              width: double.infinity,
                              height: 30,
                              labelText: 'Paid To',
                              selectedItem: selectedPaidTo,
                              onChanged: (selectedItem) {
                                debugPrint('Selected Paid To: $selectedItem');
                                setState(() {
                                  selectedPaidTo = selectedItem;
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
                        TextButton(
                          onPressed: () {
                            if (selectedPaidTo != null &&
                                amountController.text.isNotEmpty) {
                              // ✅ Update the item values
                              item.receiptFrom = selectedPaidTo!;
                              item.note = noteController.text;
                              item.amount =
                                  double.tryParse(amountController.text) ?? 0.0;

                              provider.notifyListeners(); // ✅ Refresh UI
                              Navigator.of(context).pop();

                              // Optional: Show a success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                        'Successfully, Expense item updated ')),
                              );
                            }
                          },
                          child: const Text('Update'),
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
