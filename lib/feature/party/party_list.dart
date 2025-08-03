import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/customer_create/customer_details.dart';
import 'package:cbook_dt/feature/customer_create/customer_update.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
import 'package:cbook_dt/feature/home/presentation/widget/reusable_box.dart';
import 'package:cbook_dt/feature/party/party_intro_page.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Party extends StatefulWidget {
  const Party({super.key});

  @override
  State<Party> createState() => _PartyState();
}

class _PartyState extends State<Party> {
  @override
  void initState() {
    super.initState();

    ///fetch supplier
    Future.microtask(() =>
        Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers());

    ///customer
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    ///dashboard report
    final provider =
        Provider.of<DashboardReportProvider>(context, listen: false);

    ///customer ///supplier
    Future.microtask(() async {
      await provider.fetchCustomerTransaction();
    });

    Future.microtask(() async {
      await provider.fetchSupplierTransaction();
    });

    Future.microtask(() async {
      await provider.fetchCustomerCountTransaction();
    });

    Future.microtask(() async {
      await provider.fetchTotalSupplierCount();
    });
  }

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: Row(
            children: [
              // If searching: Show search field (left side)
              if (isSearching)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 1),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 1),
                              ),
                              //filled: true,
                              fillColor: Colors.green,

                              hintText: '',
                              hintStyle: const TextStyle(fontSize: 12),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            isSearching = false;
                            searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                )
              else
                // If not searching: Show search icon + Party text + Add icon
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center: Party title
                      const Center(
                        child: Text(
                          'Party',
                          style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Left: Search icon
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = true;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.search,
                                  color: Colors.green, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Always visible: Add icon
              IconButton(
                icon: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.add, color: Colors.green)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AddNewPartyIntro(), //AddSupplierCustomer
                    ),
                  );
                },
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xffdddefa),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left (Customer)
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<DashboardReportProvider>(
                            builder: (context, provider, _) {
                              final isLoadingTransaction =
                                  provider.isLoadingCustomerTransaction;
                              final isLoadingCount =
                                  provider.isLoadingCustomerCount;

                              final errorTransaction =
                                  provider.errorCustomerTransaction;
                              final errorCount = provider.errorCustomerCount;

                              if (isLoadingTransaction || isLoadingCount) {
                                return const Text("Loading...");
                              }

                              if (errorTransaction != null ||
                                  errorCount != null) {
                                return Text(
                                    "Error: ${errorTransaction ?? errorCount}");
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                    'Customer (${provider.customerTransactionCountTotal ?? 0})',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12,
                                        fontWeight: FontWeight.bold
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '৳ ${provider.customerTransaction ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                       
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Vertical Divider
                  SizedBox(
                    height: 35,
                    width: 35,
                    //color: Colors.green.shade800,
                    //margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset('assets/image/cooperation_one.png'),
                  ),

                  // Right (Supplier)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Text("Supplier: 102",
                            ///supplier
                            Consumer<DashboardReportProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return const Center(child: SizedBox());
                                } else if (provider.error != null) {
                                  return Text("Error: ${provider.error}");
                                } else {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                        Text(
                                        'Supplier  (${provider.totalSupplierCount ?? 0})',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                            ),
                                      ),
                                      Text(
                                        '৳ ${provider.supplierTransaction ?? 0}  ',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CustomerProvider>(
                builder: (context, customerProvider, child) {
                  if (customerProvider.isLoading) {
                    return const Center(child: SizedBox());
                  }
                  if (customerProvider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        customerProvider.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  final customer =
                      customerProvider.customerResponse?.data ?? [];
                  if (customer.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Customer Found",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: customer.length,
                    itemBuilder: (context, index) {
                      final customers = customer[index];
                      final customersPurchase = customers.purchases;
                      final customerId = customers.id;
                      final customerType = customers.type;

                      return InkWell(
                        onLongPress: () => editDeleteDiolog(context,
                            customerId.toString(), customerType, customers),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailsScreen(
                                customerId: customerId,
                                purchases: customersPurchase,
                                customer: customers,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: AppColors.cardGrey,
                          //color: Colors.red,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            dense: true,
                            minVerticalPadding: 0,
                            visualDensity:
                                const VisualDensity(vertical: 0, horizontal: 0),
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              //color: Colors.red,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .white, // background color behind the image
                                    borderRadius: BorderRadius.circular(
                                        50), // rounded corners
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(
                                            0, 4), // shadow below the container
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://commercebook.site/${customers.avatar ?? ''}',
                                      fit: BoxFit.cover,
                                      height: 50,
                                      width: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                            Icons.person); // fallback
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Container(
                              //color: Colors.yellow,
                              height: 72.0, // Set your desired item height
                              padding: const EdgeInsets.only(left: 0),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  ///name, customers.proprietorName // phone, // address
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Always show the customer's name
                                      Text(
                                        customers.name,
                                        style: GoogleFonts.notoSansPhagsPa(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),

                                      // Show proprietorName if not null or empty, else show phone number
                                      Text(
                                        (customers.proprietorName != null &&
                                                customers.proprietorName!
                                                    .trim()
                                                    .isNotEmpty)
                                            ? customers.proprietorName!
                                            : customers.phone ?? 'No Phone',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.notoSansPhagsPa(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Container(
                                            width:
                                                190, // 🔧 adjust width as needed
                                            child: Text(
                                              (customers.proprietorName !=
                                                          null &&
                                                      customers.proprietorName!
                                                          .trim()
                                                          .isNotEmpty)
                                                  ? customers.phone ??
                                                      'No Phone'
                                                  : (customers.address ??
                                                          'No Address')
                                                      .replaceAll('\n', ' ')
                                                      .replaceAll('\r', ''),
                                              style:
                                                  GoogleFonts.notoSansPhagsPa(
                                                fontSize: 10,
                                                color: Colors.grey[800],
                                              ),
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              width: 140,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${customers.type![0].toUpperCase()}${customers.type!.substring(1)}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${customers.due}",
                                    style: GoogleFonts.notoSansPhagsPa(
                                      fontSize: 13,
                                      color: customers.type == 'customer'
                                          ? const Color(0xff278d46)
                                          : Colors.red[700],
                                      //fontWeight: FontWeight.w400
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  ///edit and delete.
  Future<dynamic> editDeleteDiolog(BuildContext context, String customerId,
      String? customerType, Customer customers) {
    final colorScheme = Theme.of(context).colorScheme;
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final customerList = customerProvider.customerResponse?.data ?? [];

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
                  onTap: () async {
                    Navigator.of(context).pop();

                    await Future.delayed(const Duration(milliseconds: 100));

                    if (customerType == 'suppliers') {
                      // 💡 You already have `customers` in the ListView

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerUpdate(
                            customer: CustomerData(
                              id: customers.id,
                              userId: customers.userId,
                              name: customers.name,
                              proprietorName: customers.proprietorName,
                              email: "", // or correct value
                              phone: customers.phone ?? "",
                              address: customers.address ?? "",
                              openingBalance: customers.due,
                              status: 1,
                              createdAt: "",
                              updatedAt: "",
                              type: customers.type,
                              level: null,
                              levelType: null,
                            ),
                          ),
                        ),
                      );

                      // );
                    } else if (customerType == 'customer') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerUpdate(
                            customer: CustomerData(
                              id: customers.id,
                              userId: customers.userId,
                              name: customers.name,
                              proprietorName: customers.proprietorName,
                              email: "", // or correct value
                              phone: customers.phone ?? "",
                              address: customers.address ?? "",
                              openingBalance: customers.due,
                              status: 1,
                              createdAt: "",
                              updatedAt: "",
                              type: customers.type,
                              level: null,
                              levelType: null,
                            ),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Unknown customer type: $customerType'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
                    _showDeleteDialog(context, customerId);
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

  ///delete.
  void _showDeleteDialog(BuildContext context, String customerId) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Customer/Supplier',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Customer/Supplier?',
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
              final provider =
                  Provider.of<CustomerProvider>(context, listen: false);
              bool isDeleted =
                  await provider.deleteCustomer(int.parse(customerId));

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Customer/Supplier deleted successfully!',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                );
                Navigator.of(context).pop(); // Close dialog
                await provider.fetchCustomsr(); // Refresh list
              } else {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Failed to delete Customer/Supplier',
                      style: TextStyle(color: Colors.red),
                    ),
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
