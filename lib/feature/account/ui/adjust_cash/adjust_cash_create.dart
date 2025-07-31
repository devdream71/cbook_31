import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/provider/adjust_cash_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdjustCashCreate extends StatefulWidget {
  const AdjustCashCreate({super.key});

  @override
  State<AdjustCashCreate> createState() => _AdjustCashCreateState();
}

class _AdjustCashCreateState extends State<AdjustCashCreate> {
  String? selectedAccountType;
  String? selectedAccount;

  String? selectedAdjustCashType;
  String? selectedAdjustCash;

  List<String> itemAdjustCash = [
    'Add',
    'Reduct',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<AdjustCashProvider>(context, listen: false)
          .fetchCashAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Provider.of<AdjustCashProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Adjust Cash",
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: CustomDropdownTwo(
                      hint: '',
                      items: itemAdjustCash,
                      width: double.infinity,
                      height: 40,
                      labelText: 'Adjust Cash',
                      selectedItem: selectedAdjustCashType,
                      onChanged: (value) async {
                         setState(() {
    selectedAdjustCashType = value;
    selectedAdjustCash = null; // reset account selection

    debugPrint("selectedAdjustCashType: $selectedAdjustCashType");
  });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer<AdjustCashProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.accounts.isEmpty) {
                        return const Text("No cash accounts found");
                      }

                      // Map names to dropdown items
                      final itemAdjustCash =
                          provider.accounts.map((e) => e.name).toList();

                      return SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: CustomDropdownTwo(
                          hint: '',
                          items: itemAdjustCash,
                          width: double.infinity,
                          height: 40,
                          labelText: 'Account Name',
                          selectedItem: selectedAccountType,
                          onChanged: (value) async {
                            setState(() {
                              selectedAccountType = value;

                              // get the selected account's ID if needed
                              final selected = provider.accounts.firstWhere(
                                (e) => e.name == value,
                                orElse: () => provider.accounts.first,
                              );
                              //selectedAdjustCash = selected.id;
                              selectedAccount = selected.id.toString();

                              debugPrint(
                                  "selectedCashName: $value, ID: ${selectedAccount}");
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AddSalesFormfield(
                    height: 40,
                    labelText: "Amount",
                    controller: controller.accountNameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      border: Border.all(
                          color: Colors.grey.shade300, width: 0.5), // Border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1), // Light shadow
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1), // Shadow position
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => controller.pickDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          //hintText: "Bill Date",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                          border: InputBorder.none, // Remove default underline
                        ),
                        child: Text(
                          controller.formattedDate.isNotEmpty
                              ? controller.formattedDate
                              : "No Date Provided",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AddSalesFormfield(
                    height: 40,
                    labelText: "Details",
                    controller: controller.detailsController,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userId = prefs.getInt('user_id')?.toString();

                    final provider =
                        Provider.of<AdjustCashProvider>(context, listen: false);

                    if (selectedAccountType == null ||
                        selectedAdjustCashType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select type and account.")),
                      );
                      return;
                    }

                    final result = await provider.adjustCashStore(
                      adjustCashType: selectedAdjustCashType == "Add"
                          ? "cash_add"
                          : "cash_reduct",
                      accountId: selectedAccount!, 
                      amount: provider.accountNameController.text,
                      date: provider.formattedDate,
                      details: provider.detailsController.text,
                      userId: userId!, // 🔁 change if dynamic user ID is needed
                    );

                    if (result != null && result.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(result.message)),
                      );
 
                      provider.fetchCashAccounts();
                      Navigator.of(context).pop(); // Close page if needed
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to adjust cash")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Save Adjust Cash',
                      style: TextStyle(color: Colors.white))),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
