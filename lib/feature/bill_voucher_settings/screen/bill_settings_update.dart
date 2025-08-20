import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/bill_voucher_settings/provider/bill_settings_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillSettingsUpdate extends StatefulWidget {
  const BillSettingsUpdate({super.key});

  @override
  BillSettingsUpdateState createState() => BillSettingsUpdateState();
}

class BillSettingsUpdateState extends State<BillSettingsUpdate> {
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
        
        // Navigate back to BillSettingsView with success result
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bill Setting Update',
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            children: [
              Consumer<BillSettingsProvider>(
                builder: (context, billSettings, child) {
                  if (billSettings.isLoading) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (billSettings.error != null && !billSettings.hasSettings) {
                    return SizedBox(
                      height: 200,
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

                        ///sales
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "sales Code",
                                height: 40,
                                controller: billSettings.salesCode,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "sales Bill no",
                                height: 40,
                                controller: billSettings.salesBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Sales Return Code
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "sales return Code",
                                height: 40,
                                controller: billSettings.salesReturnCode,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "sales return Bill no",
                                height: 40,
                                controller: billSettings.salesReturnBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Purchase
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
                                labelText: "Purchase Bill no",
                                height: 40,
                                controller: billSettings.purchaseBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Purchase  return
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "Purchase return Code",
                                height: 40,
                                controller: billSettings.purchaseReturnCode,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "Purchase return Bill no",
                                height: 40,
                                controller: billSettings.purchaseReturBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Recived
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
                                labelText: "Received Bill no",
                                height: 40,
                                controller: billSettings.receivedBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Payment
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
                                labelText: "Payment Bill no",
                                height: 40,
                                controller: billSettings.paymentBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Expense
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
                                labelText: "Expense Bill no",
                                height: 40,
                                controller: billSettings.expenseBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Income
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
                                labelText: "Income Bill no",
                                height: 40,
                                controller: billSettings.incomeBill,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ///Contra
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
                                labelText: "Contra Bill no",
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
                            onPressed:
                                billSettings.isUpdating ? null : _handleSave,
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
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20), // Add some bottom padding
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

