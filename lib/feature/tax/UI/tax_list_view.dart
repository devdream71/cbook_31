import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/tax/UI/add_new_tax.dart';
import 'package:cbook_dt/feature/tax/UI/tax_edit.dart';
import 'package:cbook_dt/feature/tax/model/tax_model.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TaxListView extends StatelessWidget {
  const TaxListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    // Fetch tax data when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taxProvider.fetchTaxes();
    });

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'Tax List',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          // Always visible: Add icon
          IconButton(
            icon: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: Colors.green)),
            onPressed: () async {
             final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTax(), //AddSupplierCustomer
                ),
              );

                // Refresh the list when returning from AddNewTax
    if (result == true) {
      Provider.of<TaxProvider>(context, listen: false).fetchTaxes();
    }

              
            },
          ),
        ],
      ),
      body: Consumer<TaxProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          
          if (provider.taxList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset('assets/animation/no_data.json'),
                  ),
                  const SizedBox(height: 16),
                  
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.taxList.length,
            itemBuilder: (context, index) {
              final TaxModel tax = provider.taxList[index];

              final taxId = provider.taxList[index].id;

              return InkWell(
                onLongPress: () {
                  editDeleteDiolog(context, taxId);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),

                  //margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      tax.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Percent: ${tax.percent}%",
                          style: const TextStyle(fontSize: 12),
                        ),
                        // Text(
                        //     "Status: ${tax.status == 1 ? 'Active' : 'Inactive'}"),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  ///edit and delete pop up.
  Future<dynamic> editDeleteDiolog(BuildContext context, int taxId) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16), // Adjust side padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Height as per content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Action',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border.all(
                              color: Colors.grey,
                              width: 1), // Border color and width
                          borderRadius: BorderRadius.circular(
                              50), // Corner radius, adjust as needed
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary, // Use your color
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    //Navigate to Edit Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaxEdit(taxId: taxId),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                // const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, taxId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete',
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///delete bill person.
  void _showDeleteDialog(BuildContext context, int taxId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Tax Vat',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Tax Vat?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              
              final provider = Provider.of<TaxProvider>(context, listen: false);

              bool success = await provider.deleteTax(taxId);

              Navigator.of(context).pop(); // Close dialog

              if (success) {
                await provider.fetchTaxes(); // ✅ Reload updated list

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('successfully, Tax Vat deleted.'),
                  ),
                );
                
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Failed to delete tax."),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
