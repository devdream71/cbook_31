import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/customer_details.dart';
import 'package:cbook_dt/feature/customer_create/customer_update.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerListScreen extends StatefulWidget {
  @override
  CustomerListScreenState createState() => CustomerListScreenState();
}

class CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        title: const Text('Customers',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomerCreate()),
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
                  "Add Customers",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Consumer<CustomerProvider>(
                builder: (context, customerProvider, child) {
                  if (customerProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (customerProvider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        customerProvider.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  // final customer =
                  //     customerProvider.customerResponse?.data.values.toList() ?? [];

                  final customer =
                      customerProvider.customerResponse?.data ?? [];

                  if (customer.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Customer Found",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(4),
                      itemCount: customer.length,
                      itemBuilder: (context, index) {
                        final customers = customer[index];
                        final customersPurchaase = customer[index].purchases;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailsScreen(
                                  customerId: customers.id,
                                  purchases: customersPurchaase,
                                  customer: customers,
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
                                contentPadding: const EdgeInsets.only(left: 17),
                                title: Text(
                                  customers.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      customers.address != null
                                          ? customers.address.toString()
                                          : "No Address",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 140, // Adjust width as needed
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "৳ ${customers.due}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      PopupMenuButton<String>(
                                        position: PopupMenuPosition.under,
                                        onSelected: (value) async {
                                          if (value == 'Edit') {
                                            final customerProvider =
                                                Provider.of<CustomerProvider>(
                                                    context,
                                                    listen: false);

                                            debugPrint(
                                                "Clicked Edit for Supplier ID: ${customers.id}");

                                            // Fetch supplier data by ID
                                            final customerData =
                                                await customerProvider
                                                    .fetchCustomerById(
                                                        customers.id);

                                            if (customerData != null) {
                                              debugPrint(
                                                  "Fetched Supplier Data: ${customerData.id}");

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CustomerUpdate(
                                                          customer:
                                                              customerData),
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
                                            final confirm = await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    "Delete Customer"),
                                                content: const Text(
                                                  "Are you sure you want to delete this Customer?",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    child: const Text("Delete",
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              await Provider.of<
                                                          CustomerProvider>(
                                                      context,
                                                      listen: false)
                                                  .deleteCustomer(customers.id);
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
