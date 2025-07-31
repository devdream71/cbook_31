import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/account_type/provider/account_type_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountyTypeUpdate extends StatefulWidget {
  final int accId;
  const AccountyTypeUpdate({super.key, required this.accId});

  @override
  State<AccountyTypeUpdate> createState() => _AccountyTypeUpdateState();
}

class _AccountyTypeUpdateState extends State<AccountyTypeUpdate> {
  List<String> itemList = [
    'Cash',
    'Bank',
    'Direct Income',
    'Indirect Income',
    'Direct Expense',
    'Indirect Expense'
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AccountTypeProvider>(context, listen: false);
    provider.fetchAccountById(widget.accId).then((_) {
      setState(() => isLoading = false);
    });
  }

  Future<void> submitUpdateAccount() async {
    final provider = Provider.of<AccountTypeProvider>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getInt('user_id')?.toString();

    final isSuccess = await provider.updateAccount(
      id: widget.accId,
      userId: userId!,
    );

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully,Account updated."),
          backgroundColor: Colors.green,
        ),
      );

      provider.fetchAccounts();

      Navigator.pop(context); // 👈 Go back after update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update account"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountTypeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Account Type Update",
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AddSalesFormfield(
                          height: 40,
                          labelText: "Account Name",
                          controller: provider.accountNameController,
                        ),
                        // const SizedBox(height: 10),
                        // AddSalesFormfield(
                        //   height: 40,
                        //   labelText: "Account Group",
                        //   controller: provider.accountGroupController,
                        // ),
                        const SizedBox(height: 10),
                        AddSalesFormfield(
                          height: 40,
                          labelText: "Account Balance",
                          controller: provider.openBlanceController,
                        ),
                        const SizedBox(height: 10),
                        CustomDropdownTwo(
                          hint: '',
                          items: itemList,
                          width: double.infinity,
                          height: 40,
                          labelText: 'Account Type',
                          selectedItem: provider.selectedAccountType,
                          onChanged: (value) {
                            provider.selectedAccountType = value!;
                            provider.notifyListeners();
                          },
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => provider.pickDate(context),
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Text(
                                provider.formattedDate.isNotEmpty
                                    ? provider.formattedDate
                                    : "Pick Date",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // CustomDropdownTwo(
                        //   items: const ["Active", "Inactive"],
                        //   labelText: 'Status',
                        //   width: double.infinity,
                        //   height: 40,
                        //   value: provider.selectedStatus == "1"
                        //       ? "Active"
                        //       : "Inactive",
                        //   onChanged: (value) {
                        //     provider.selectedStatus =
                        //         (value == "Active") ? "1" : "0";
                        //     provider.notifyListeners();
                        //   },
                        // ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        submitUpdateAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("Update Account",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
    );
  }
}
