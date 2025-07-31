import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/adjust_bank/provider/bank_adjust_provider.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/provider/adjust_cash_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdjustBankCreate extends StatefulWidget {
  const AdjustBankCreate({super.key});

  @override
  State<AdjustBankCreate> createState() => _AdjustBankCreateState();
}

class _AdjustBankCreateState extends State<AdjustBankCreate> {
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
    Future.microtask(() {
      Provider.of<BankAdjustProvider>(context, listen: false)
          .fetchBankAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Provider.of<BankAdjustProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Adjust Bank",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
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
                            selectedAdjustCash =
                                null; // reset account selection

                            debugPrint(
                                "selectedAccountType  ${selectedAdjustCash}");
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Consumer<BankAdjustProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (provider.bankAccounts.isEmpty) {
                          return const Text("No bank accounts found");
                        }

                        final itemBankAccounts =
                            provider.bankAccounts.map((e) => e.name).toList();

                        return SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            hint: '',
                            items: itemBankAccounts,
                            width: double.infinity,
                            height: 40,
                            labelText: 'Account Name',
                            selectedItem: selectedAccountType,
                            onChanged: (value) async {
                              setState(() {
                                selectedAccountType = value;

                                final selected =
                                    provider.bankAccounts.firstWhere(
                                  (e) => e.name == value,
                                  orElse: () => provider.bankAccounts.first,
                                );

                                selectedAccount = selected.id.toString();

                                debugPrint(
                                    "Selected Bank Account: $value, ID: $selectedAccount");
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
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
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
                            border:
                                InputBorder.none, // Remove default underline
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

                      if (selectedAdjustCashType == null ||
                          selectedAccount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Select all required fields")),
                        );
                        return;
                      }

                      final result = await controller.submitBankAdjustment(
                        userId:
                            userId!, // replace with logged-in user ID if dynamic
                        adjustType: selectedAdjustCashType == 'Add'
                            ? 'cash_add'
                            : 'cash_reduce',
                        accountId: selectedAccount!,
                        amount: controller.accountNameController.text.trim(),
                        date: controller.formattedDate,
                        details: controller.detailsController.text.trim(),
                      );

                      if (result != null && result.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(result.message)),
                        );

                        //controller.fetchCashAccounts();
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to save adjustment")),
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
                    child: const Text('Save Adjust Bank',
                        style: TextStyle(color: Colors.white))),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ));
  }
}
