import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/bill_settings_provider.dart';

class BillSettingsView extends StatefulWidget {
  const BillSettingsView({super.key});

  @override
  State<BillSettingsView> createState() => _BillSettingsViewState();
}

class _BillSettingsViewState extends State<BillSettingsView> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final billSettings =
          Provider.of<BillSettingsProvider>(context, listen: false);
      // Fetch settings first, then populate controllers
      if (!billSettings.hasSettings) {
        billSettings.fetchSettings().then((_) {
          billSettings.populateControllers();
          setState(() {
            isChecked = billSettings.getWithNickNameStatus();
          });
        });
      } else {
        billSettings.populateControllers();
        setState(() {
          isChecked = billSettings.getWithNickNameStatus();
        });
      }
    });
  }

  Future<void> _handleSave() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final billSettings =
        Provider.of<BillSettingsProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Updating settings..."),
            ],
          ),
        );
      },
    );

    try {
      final success = await billSettings.updateSettings(isChecked);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: ${billSettings.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'Bill Settings',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Consumer<BillSettingsProvider>(
            builder: (context, billSettings, child) {
              if (billSettings.isLoading) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (billSettings.error != null && !billSettings.hasSettings) {
                return SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${billSettings.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => billSettings.fetchSettings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                      title: const Text(
                        "With Nick Name",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      onTap: () {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                    ),

                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Prefixes",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Numbers",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Sales
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Sales Code",
                            height: 40,
                            controller: billSettings.salesCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Sales Bill No",
                            height: 40,
                            controller: billSettings.salesBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Sales Return
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Sales Return Code",
                            height: 40,
                            controller: billSettings.salesReturnCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Sales Return Bill No",
                            height: 40,
                            controller: billSettings.salesReturnBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Purchase
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Purchase Code",
                            height: 40,
                            controller: billSettings.purchaseCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Purchase Bill No",
                            height: 40,
                            controller: billSettings.purchaseBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Purchase Return
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Purchase Return Code",
                            height: 40,
                            controller: billSettings.purchaseReturnCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Purchase Return Bill No",
                            height: 40,
                            controller: billSettings.purchaseReturBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Received
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Received Code",
                            height: 40,
                            controller: billSettings.receivedCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Received Bill No",
                            height: 40,
                            controller: billSettings.receivedBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Payment
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Payment Code",
                            height: 40,
                            controller: billSettings.paymentCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Payment Bill No",
                            height: 40,
                            controller: billSettings.paymentBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Expense
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Expense Code",
                            height: 40,
                            controller: billSettings.expenseCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Expense Bill No",
                            height: 40,
                            controller: billSettings.expenseBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Income
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Income Code",
                            height: 40,
                            controller: billSettings.incomeCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Income Bill No",
                            height: 40,
                            controller: billSettings.incomeBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Contra
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Contra Code",
                            height: 40,
                            controller: billSettings.contraCode,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AddSalesFormfield(
                            labelText: "Contra Bill No",
                            height: 40,
                            controller: billSettings.contraBill,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: billSettings.isUpdating ? null : _handleSave,
                        child: billSettings.isUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Settings',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}




// import 'package:cbook_dt/app_const/app_colors.dart';
// import 'package:cbook_dt/feature/bill_voucher_settings/screen/bill_settings_update.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../provider/bill_settings_provider.dart';

// class BillSettingsView extends StatefulWidget {
//   const BillSettingsView({super.key});

//   @override
//   State<BillSettingsView> createState() => _BillSettingsViewState();
// }

// class _BillSettingsViewState extends State<BillSettingsView> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch settings when the page loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider =
//           Provider.of<BillSettingsProvider>(context, listen: false);
//       if (!provider.hasSettings) {
//         provider.fetchSettings();
//       }
//     });
//   }

//   Future<void> _navigateToUpdate() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const BillSettingsUpdate(),
//       ),
//     );

//     // If update was successful, refresh the settings
//     if (result == true && mounted) {
//       final provider =
//           Provider.of<BillSettingsProvider>(context, listen: false);
//       await provider.fetchSettings();

//       // Show a success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Settings refreshed successfully!'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: AppColors.sfWhite,
//       appBar: AppBar(
//         backgroundColor: colorScheme.primary,
//         centerTitle: true,
//         title: const Text(
//           'Bill Settings',
//           style: TextStyle(
//               color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         automaticallyImplyLeading: true,
//         actions: [
//           InkWell(
//             onTap: _navigateToUpdate,
//             child: const Padding(
//               padding: EdgeInsets.only(right: 16.0),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.edit, color: Colors.white, size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     'Update',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Consumer<BillSettingsProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.error != null && !provider.hasSettings) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.red.shade300,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error loading settings',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     provider.error!,
//                     style: const TextStyle(fontSize: 14, color: Colors.black54),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () => provider.fetchSettings(),
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Retry'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colorScheme.primary,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (provider.settings.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.settings_outlined,
//                     size: 64,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'No settings found',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Configure your bill settings to get started',
//                     style: TextStyle(fontSize: 14, color: Colors.black54),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: _navigateToUpdate,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Settings'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colorScheme.primary,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () => provider.fetchSettings(),
//             child: ListView.separated(
//               shrinkWrap: true,
//               padding: const EdgeInsets.all(4),
//               itemCount: provider.settings.length,
//               separatorBuilder: (context, index) => const SizedBox(height: 2),
//               itemBuilder: (context, index) {
//                 final setting = provider.settings[index];
//                 return Card(
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.zero, // radius 0
//                   ),

//                   //elevation: 2,
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 0,
//                     ),
//                     leading: Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: colorScheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         Icons.settings,
//                         color: colorScheme.primary,
//                         size: 20,
//                       ),
//                     ),
//                     title: Text(
//                       _formatSettingKey(setting.data),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     subtitle: Text(
//                       setting.value ?? 'N/A',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Helper method to format setting keys for better display
//   String _formatSettingKey(String key) {
//     return key
//         .replaceAll('_', ' ')
//         .split(' ')
//         .map((word) =>
//             word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
//         .join(' ');
//   }
// }
