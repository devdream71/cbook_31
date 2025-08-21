import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/tax/UI/add_new_tax.dart';
import 'package:cbook_dt/feature/tax/UI/tax_edit.dart';
import 'package:cbook_dt/feature/tax/model/tax_model.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TaxListView extends StatefulWidget {
  const TaxListView({super.key});

  @override
  State<TaxListView> createState() => _TaxListViewState();
}


class _TaxListViewState extends State<TaxListView> {
  @override
  void initState() {
    super.initState();
    // Fetch tax data when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaxProvider>(context, listen: false).fetchTaxes();
    });
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
          'Tax List',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: Colors.green)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTax(),
                ),
              );

              // Refresh the list when returning
              if (result == true && mounted) {
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
                  const Text(
                    'No tax records found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchTaxes();
            },
            child: ListView.builder(
              itemCount: provider.taxList.length,
              itemBuilder: (context, index) {
                final TaxModel tax = provider.taxList[index];

                return InkWell(
                  onLongPress: () {
                    _showEditDeleteDialog(tax.id);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ///edit and delete popup.
  void _showEditDeleteDialog(int taxId) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    
                    // Navigate to edit page and handle result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaxEdit(taxId: taxId),
                      ),
                    );

                    // Refresh list if edit was successful
                    if (result == true && mounted) {
                      Provider.of<TaxProvider>(context, listen: false).fetchTaxes();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmation(taxId);
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

  ///delete confirmation dialog
  void _showDeleteConfirmation(int taxId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Tax',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this tax?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close confirmation dialog
              _deleteTax(taxId); // Start delete process
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ SIMPLE and RELIABLE delete method
  void _deleteTax(int taxId) async {
    debugPrint('🗑️ Starting delete for tax ID: $taxId');
    
    // ✅ Store the current context
    final currentContext = context;
    
    // Show loading dialog
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Deleting tax...'),
          ],
        ),
      ),
    );

    try {
      // Perform the delete operation
      final provider = Provider.of<TaxProvider>(currentContext, listen: false);
      bool success = await provider.deleteTax(taxId);
      
      debugPrint('🗑️ Delete result: $success');

      // ✅ ALWAYS pop the loading dialog first
      Navigator.of(currentContext).pop();
      debugPrint('🗑️ Loading dialog closed');

      // ✅ Small delay to ensure dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 100));

      // Show result message
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Tax deleted successfully!',
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          debugPrint('✅ Success message shown');
        } else {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Failed to delete tax.",
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 3),
            ),
          );
          // Refresh list on failure
          provider.fetchTaxes();
          debugPrint('❌ Failure message shown, list refreshed');
        }
      }
    } catch (e) {
      debugPrint('💥 Exception during delete: $e');
      
      // ✅ Ensure dialog is closed on exception
      try {
        Navigator.of(currentContext).pop();
        debugPrint('🗑️ Loading dialog closed due to exception');
      } catch (navError) {
        debugPrint('⚠️ Error closing dialog: $navError');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Error: $e",
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}