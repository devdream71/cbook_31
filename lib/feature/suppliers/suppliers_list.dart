
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:cbook_dt/feature/suppliers/supplier_update.dart';
import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';
import 'package:cbook_dt/feature/suppliers/supplies_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  SupplierListScreenState createState() => SupplierListScreenState();
}

class SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        title: const Text('Suppliers',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SuppliersCreate()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Add Suppliers",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Consumer<SupplierProvider>(
                builder: (context, supplierProvider, child) {
                  if (supplierProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                      
                  if (supplierProvider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        supplierProvider.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                      
                  // final suppliers =
                  //     supplierProvider.supplierResponse?.data.values.toList() ?? [];
                      
                  final suppliers = supplierProvider.supplierResponse?.data ?? [];
                      
                  if (suppliers.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Suppliers Found",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    );
                  }
                      
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(4),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        final supplierPurchase = suppliers[index].purchases;
                            
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SupplierDetailsScreen(
                                  supplierId: supplier.id,
                                  purchases: supplierPurchase,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ListTile(
                               contentPadding: const EdgeInsets.only(left: 16),

                                title: Text(
                                  supplier.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  supplier.proprietorName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 12),
                                ),
                                trailing: SizedBox(
                                  width: 140, // Adjust width as needed
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "৳ ${supplier.due}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      PopupMenuButton<String>(
                                        position: PopupMenuPosition.under,
                                        onSelected: (value) async {
                                          if (value == 'Edit') {
                                            final supplierProvider =
                                                Provider.of<
                                                        SupplierProvider>(
                                                    context,
                                                    listen: false);
                            
                                            debugPrint(
                                                "Clicked Edit for Supplier ID: ${supplier.id}");
                            
                                            // Fetch supplier data by ID
                                            final supplierData =
                                                await supplierProvider
                                                    .fetchSupplierById(
                                                        supplier.id);
                            
                                            if (supplierData != null) {
                                              debugPrint(
                                                  "Fetched Supplier Data: ${supplierData.id}");
                            
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SupplierUpdate(
                                                          supplier:
                                                              supplierData),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "Failed to fetch supplier details")),
                                              );
                                            }
                                          } else if (value == 'delete') {
                                            final confirm =
                                                await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AlertDialog(
                                                title: const Text(
                                                    "Delete Supplier"),
                                                content: const Text(
                                                    "Are you sure you want to delete this supplier?", style: TextStyle(color: Colors.black),),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: const Text(
                                                        "Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    child: const Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .red)),
                                                  ),
                                                ],
                                              ),
                                            );
                            
                                            if (confirm == true) {
                                              await Provider.of<
                                                          SupplierProvider>(
                                                      context,
                                                      listen: false)
                                                  .deleteSupplier(
                                                      supplier.id);
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'Edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit,
                                                  color: Colors.blue),
                                              title: Text('Edit'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete,
                                                  color: Colors.red),
                                              title: Text('Delete'),
                                            ),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
         
         
          ],
        ),
      ),
    );
  }
}
