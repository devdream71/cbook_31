import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/account_type/provider/account_type_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountTypeCreate extends StatefulWidget {
  const AccountTypeCreate({super.key});

  @override
  State<AccountTypeCreate> createState() => _AccountTypeCreateState();
}

class _AccountTypeCreateState extends State<AccountTypeCreate> {
  String? selectedAccountType;
  bool showBankDetails = false;
  String? selectedAccount;

  String selectedStatus = "1";

  final Map<String, String> accountTypeMap = {
    "Cash in Hand": "cash",
    "Bank": "bank",
    "Direct Income": "direct_income",
    "Indirect Income": "indirect_income",
    "Direct Expense": "direct_expense",
    "Indirect Expense": "indirect_expense",
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Provider.of<AccountTypeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Account List",
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
                  ///account name
                  AddSalesFormfield(
                    height: 40,
                    labelText: "Account Name",
                    controller: controller.accountNameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                 

                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: CustomDropdownTwo(
                      hint: '',
                      items: accountTypeMap.keys.toList(), // show labels
                      width: double.infinity,
                      height: 40,
                      labelText: 'Account Type',
                      selectedItem: selectedAccountType,
                      onChanged: (value) async {
                        setState(() {
                          selectedAccountType = value;

                          // Get the mapped backend value
                          final backendValue = accountTypeMap[value] ?? "";

                          selectedAccount =
                              backendValue; // store correct value for API

                          debugPrint(
                              "selectedAccountType (UI)  $selectedAccountType");
                          debugPrint("selectedAccount (API)  $selectedAccount");
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  ///acount balance
                  AddSalesFormfield(
                    height: 40,
                    labelText: "Opening Balance",
                    controller: controller.openBlanceController,
                  ),

                  
                  const SizedBox(
                    height: 10,
                  ),

                  ///date
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

                  /// If "Bank" is selected, show checkbox to enable bank detail form
                  ///

                  /// If "Bank" is selected, show checkbox to enable bank detail form
                  if (selectedAccountType?.toLowerCase() == 'bank') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Checkbox(
                            value: showBankDetails,
                            onChanged: (value) {
                              setState(() {
                                showBankDetails = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Add Bank Details",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],

                  /// Show bank form if checkbox is checked
                  if (selectedAccountType?.toLowerCase() == 'bank' &&
                      showBankDetails) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AddSalesFormfield(
                        height: 40,
                        labelText: "Account Holder Name",
                        controller: controller.accountHolderNameController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AddSalesFormfield(
                        height: 40,
                        labelText: "Account No",
                        controller: controller.accountNoController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AddSalesFormfield(
                        height: 40,
                        labelText: "Routing/IFSC Number",
                        controller: controller.routingNumberController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AddSalesFormfield(
                        height: 40,
                        labelText: "Bank Location",
                        controller: controller.bankLocationController,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  
                ],
              ),
            ),


            // Replace your ElevatedButton's onPressed method with this improved version:

SizedBox(
  height: 40,
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      // Validate required fields first
      if (controller.accountNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an account name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
  
      if (selectedAccount == null || selectedAccount!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an account type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
  
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getInt('user_id')?.toString();
  
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
  
        final provider = Provider.of<AccountTypeProvider>(context, listen: false);
  
        debugPrint('selectedAccount: $selectedAccount');
  
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  
        final result = await controller.createAccount(
          userId: userId,
          accountName: controller.accountNameController.text.trim(),
          accountType: selectedAccount!,
          accountGroup: controller.accountGroupController.text.trim(),
          openingBalance: controller.openBlanceController.text.trim(),
          date: controller.formattedDate.isNotEmpty
              ? controller.formattedDate
              : '2025-09-10',
          status: selectedStatus,
          accountHolderName: selectedAccountType?.toLowerCase() == 'bank'
              ? controller.accountHolderNameController.text.trim()
              : null,
          accountNo: selectedAccountType?.toLowerCase() == 'bank'
              ? controller.accountNoController.text.trim()
              : null,
          routingNumber: selectedAccountType?.toLowerCase() == 'bank'
              ? controller.routingNumberController.text.trim()
              : null,
          bankLocation: selectedAccountType?.toLowerCase() == 'bank'
              ? controller.bankLocationController.text.trim()
              : null,
        );
  
        // Hide loading indicator
        Navigator.of(context).pop();
  
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Account created successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
  
          // Refresh the accounts list
          provider.fetchAccounts();
  
          // Reset all form fields using controller method
          controller.resetForm();
  
          // Reset widget state variables
          setState(() {
            selectedAccountType = null;
            selectedAccount = null;
            selectedStatus = "1";
            showBankDetails = false;
          });
  
          Navigator.pop(context);
        } else {
          // Handle specific error messages from the API
          String errorMessage = result.message ?? 'Failed to create account';
          
          // Check for specific error cases and provide user-friendly messages
          if (errorMessage.contains('Already exit this account')) {
            errorMessage = 'An account with this name already exists. Please choose a different name.';
          }
  
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              // action: SnackBarAction(
              //   label: 'OK',
              //   textColor: Colors.white,
              //   onPressed: () {
              //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //   },
              // ),
            ),
          );
        }
      } catch (e) {
        // Hide loading indicator if it's showing
        Navigator.of(context, rootNavigator: true).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    child: const Text(
      'Save Account',
      style: TextStyle(color: Colors.white),
    ),
  ),
),

            // SizedBox(
            //   height: 40,
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       SharedPreferences prefs =
            //           await SharedPreferences.getInstance();
            //       String? userId = prefs.getInt('user_id')?.toString();

            //       final provider =
            //           Provider.of<AccountTypeProvider>(context, listen: false);

            //           debugPrint( 'selectedAccount  ${selectedAccount}');

            //       final result = await controller.createAccount(
            //         userId: userId.toString(),
            //         accountName: controller.accountNameController.text.trim(),
            //         accountType: selectedAccount! ,
                    
            //         accountGroup: controller.accountGroupController.text.trim(),
            //         openingBalance: controller.openBlanceController.text.trim(),
            //         date: controller.formattedDate.isNotEmpty
            //             ? controller.formattedDate
            //             : '2025-07-14',
            //         status: selectedStatus,
            //         accountHolderName:
            //             selectedAccountType?.toLowerCase() == 'bank'
            //                 ? controller.accountHolderNameController.text.trim()
            //                 : null,
            //         accountNo: selectedAccountType?.toLowerCase() == 'bank'
            //             ? controller.accountNoController.text.trim()
            //             : null,
            //         routingNumber: selectedAccountType?.toLowerCase() == 'bank'
            //             ? controller.routingNumberController.text.trim()
            //             : null,
            //         bankLocation: selectedAccountType?.toLowerCase() == 'bank'
            //             ? controller.bankLocationController.text.trim()
            //             : null,
            //       );

            //       if (result.success) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             content: Text(result.message),
            //             backgroundColor: Colors.green,
            //           ),
            //         );

            //         // Refresh the accounts list
            //         provider.fetchAccounts();

            //         // ✅ Reset all form fields using controller method
            //         controller.resetForm();

            //         // ✅ Reset widget state variables
            //         setState(() {
            //           selectedAccountType = null;
            //           selectedAccount = null;
            //           selectedStatus = "1";
            //           showBankDetails = false;
            //         });

            //         Navigator.pop(context);
            //       } else {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             content: Text(result.message),
            //             backgroundColor: Colors.red,
            //           ),
            //         );
            //       }
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor,
            //       padding:
            //           const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //     ),
            //     child: const Text(
            //       'Save Account Type',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),

            

            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
