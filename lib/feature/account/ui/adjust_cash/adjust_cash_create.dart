import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/model/adjust_cash.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/provider/adjust_cash_provider.dart';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/provider/cash_in_hand.dart';
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

  // Add this flag to prevent multiple saves
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback instead of Future.delayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AdjustCashProvider>(context, listen: false)
            .fetchCashAccounts();
      }
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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ///adjust cash.
                    // SizedBox(
                    //   height: 40,
                    //   width: double.infinity,
                    //   child: CustomDropdownTwo(
                    //     hint: '',
                    //     items: itemAdjustCash,
                    //     width: double.infinity,
                    //     height: 40,
                    //     labelText: 'Adjust Cash',
                    //     selectedItem: selectedAdjustCashType,
                    //     onChanged: (value) {
                    //       if (mounted) {
                    //         setState(() {
                    //           selectedAdjustCashType = value;
                    //           selectedAdjustCash =
                    //               null; // reset account selection
                    //           debugPrint(
                    //               "selectedAdjustCashType: $selectedAdjustCashType");
                    //         });
                    //       }
                    //     },
                    //   ),
                    // ),

                    // Replace the SizedBox dropdown with this radio button widget
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.symmetric(
                    //       vertical: 8, horizontal: 12),

                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [

                    //       const SizedBox(height: 4),
                    //       Row(
                    //         children: itemAdjustCash.map((option) {
                    //           return Expanded(
                    //             child: Row(

                    //               children: [
                    //                 Radio<String>(
                    //                   value: option,
                    //                   groupValue: selectedAdjustCashType,
                    //                   onChanged: (value) {
                    //                     if (mounted) {
                    //                       setState(() {
                    //                         selectedAdjustCashType = value;
                    //                         selectedAdjustCash =
                    //                             null; // reset account selection
                    //                         debugPrint(
                    //                             "selectedAdjustCashType: $selectedAdjustCashType");
                    //                       });
                    //                     }
                    //                   },
                    //                   materialTapTargetSize:
                    //                       MaterialTapTargetSize.shrinkWrap,
                    //                   visualDensity: VisualDensity.compact,
                    //                 ),
                    //                 Text(
                    //                   option,
                    //                   style: const TextStyle(
                    //                       fontSize: 14, color: Colors.black),
                    //                 ),
                    //               ],
                    //             ),
                    //           );
                    //         }).toList(),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: itemAdjustCash.map((option) {
                              return Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center the radio button and text
                                  children: [
                                    Radio<String>(
                                      value: option,
                                      groupValue: selectedAdjustCashType,
                                      onChanged: (value) {
                                        if (mounted) {
                                          setState(() {
                                            selectedAdjustCashType = value;
                                            selectedAdjustCash =
                                                null; // reset account selection
                                            debugPrint(
                                                "selectedAdjustCashType: $selectedAdjustCashType");
                                          });
                                        }
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text(
                                      option,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// cash account , if not found show default account cash.
                    Consumer<AdjustCashProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        // Default "Cash" account (id = 1)
                        final defaultCashAccount =
                            AdjustCash(id: 1, name: "Cash");

                        // Merge default cash with API accounts
                        final allAccounts = [
                          defaultCashAccount,
                          ...provider.accounts
                        ];

                        // Map names to dropdown items
                        final itemAdjustCash =
                            allAccounts.map((e) => e.name).toList();

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
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  selectedAccountType = value;

                                  // get the selected account's ID if needed
                                  final selected = allAccounts.firstWhere(
                                    (e) => e.name == value,
                                    orElse: () => defaultCashAccount,
                                  );

                                  selectedAccount = selected.id.toString();

                                  debugPrint(
                                    "selectedCashName: $value, ID: $selectedAccount",
                                  );
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                    AddSalesFormfield(
                      height: 40,
                      labelText: "Amount",
                      keyboardType: TextInputType.number,
                      controller: controller.accountNameController,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 40,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
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
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                            border: InputBorder.none,
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
                    const SizedBox(height: 10),
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
                  onPressed: _isSaving
                      ? null
                      : _handleSave, // Disable button when saving
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Adjust Cash',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    // Prevent multiple saves
    if (_isSaving || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    FocusScope.of(context).unfocus();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getInt('user_id')?.toString();

      final provider = Provider.of<AdjustCashProvider>(context, listen: false);

      // Validation
      if (selectedAccountType == null || selectedAdjustCashType == null) {
        _showSnackBar("Please select type and account.", Colors.red);
        return;
      }

      if (provider.accountNameController.text.trim().isEmpty) {
        _showSnackBar("Please enter amount.", Colors.red);
        return;
      }

      if (userId == null) {
        _showSnackBar("User ID not found. Please login again.", Colors.red);
        return;
      }

      // Call the API
      final result = await provider.adjustCashStore(
        adjustCashType:
            selectedAdjustCashType == "Add" ? "cash_add" : "cash_reduct",
        accountId: selectedAccount!,
        amount: provider.accountNameController.text,
        date: provider.formattedDate,
        details: provider.detailsController.text,
        userId: userId,
      );

      if (!mounted) return;

      if (result != null && result.success) {
        // Clear form data
        _clearForm(provider);

        // Show success message
        _showSnackBar(result.message, Colors.green);

        final listcash =
            Provider.of<CashInHandProvider>(context, listen: false);

        await listcash.fetchCashInHandData();

        Navigator.of(context).pop();
      } else {
        _showSnackBar("Failed to adjust cash", Colors.red);
      }
    } catch (e) {
      debugPrint("Error in save operation: $e");
      if (mounted) {
        _showSnackBar("An error occurred. Please try again.", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

// Add this helper method to clear the form
  void _clearForm(AdjustCashProvider provider) {
    if (mounted) {
      setState(() {
        selectedAccountType = null;
        selectedAccount = null;
        selectedAdjustCashType = null;
        selectedAdjustCash = null;
      });
    }

    provider.accountNameController.clear();
    provider.detailsController.clear();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Reset the saving flag when disposing
    _isSaving = false;
    super.dispose();
  }
}
