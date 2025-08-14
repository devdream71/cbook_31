import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/app_service_free_premium/controler/app_service_controller.dart';
import 'package:cbook_dt/feature/app_service_free_premium/screen/app_service.dart'; 
import 'package:cbook_dt/feature/settings/ui/bill/bill_create.dart';
import 'package:cbook_dt/feature/settings/ui/bill/edit_bill_person.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillPersonList extends StatefulWidget {
  const BillPersonList({super.key});

  @override
  State<BillPersonList> createState() => _BillPersonListState();
}

class _BillPersonListState extends State<BillPersonList> {
  @override
  void initState() {
    super.initState();

    // ✅ First fetch app service to check if user has premium access
    Future.microtask(() async {
      debugPrint("=== BILL PERSON LIST INIT ===");
      
      final appServiceProvider = Provider.of<AppServiceProvider>(context, listen: false);
      debugPrint("About to fetch app service...");
      
      await appServiceProvider.fetchAppService();
      
      debugPrint("App service fetch completed");
      debugPrint("App Service: '${appServiceProvider.appService}'");
      debugPrint("Is Free: ${appServiceProvider.isFree}");
      
      // ✅ Only fetch bill persons if user has premium access
      if (!appServiceProvider.isFree) {
        debugPrint("User has premium access - fetching bill persons");
        Provider.of<BillPersonProvider>(context, listen: false).fetchBillPersons();
      } else {
        debugPrint("User has free access - NOT fetching bill persons");
      }
      
      debugPrint("=== END BILL PERSON LIST INIT ===");
    });
  }

  TextStyle ts = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  TextStyle ts2 = const TextStyle(color: Colors.black, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      body: Consumer<AppServiceProvider>(
        builder: (context, appServiceProvider, child) {
          // ✅ Add debugging in build method
          debugPrint("=== BUILD METHOD DEBUG ===");
          debugPrint("isLoading: ${appServiceProvider.isLoading}");
          debugPrint("appService: '${appServiceProvider.appService}'");
          debugPrint("isFree: ${appServiceProvider.isFree}");

          // ✅ Show loading while checking app service
          if (appServiceProvider.isLoading) {
            debugPrint("Showing loading screen");
            return Scaffold(
              backgroundColor: AppColors.sfWhite,
              appBar: AppBar(
                backgroundColor: colorScheme.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  'Bill Person',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Checking app service..."),
                  ],
                ),
              ),
            );
          }

          // ✅ If app service is free, show AppServiceUI
          if (appServiceProvider.isFree) {
            debugPrint("Showing AppServiceUI (free version)");
            return const AppServiceUI();
          }

          // ✅ If app service is premium, show BillPersonList content
          debugPrint("Showing premium BillPersonList content");
          return _buildBillPersonListContent(colorScheme);
        },
      ),
    );
  }

  // ✅ Extract the original BillPersonList content into a separate method
  Widget _buildBillPersonListContent(ColorScheme colorScheme) {
    debugPrint("Building premium bill person list content");
    
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            const Text(
              'Bill Person',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillCreate()),
                );
              },
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Add bill person',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<BillPersonProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage.isNotEmpty) {
                  return Center(child: Text(provider.errorMessage));
                }

                if (provider.billPersons.isEmpty) {
                  return Center(
                    child: Text('No Bill Persons Found', style: ts),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero, // 🔥 Zero padding
                  itemCount: provider.billPersons.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 1), // 🔥 Zero space between items
                  itemBuilder: (context, index) {
                    final person = provider.billPersons[index];
                    final billPersonId = provider.billPersons[index].id;

                    return InkWell(
                      onLongPress: () {
                        editDeleteDiolog(context, billPersonId.toString());
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(
                              255, 241, 240, 240), // Optional: background color
                        ),
                        child: ListTile(
                          dense: true, // 🔥 Makes the tile more compact
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0), // 🔥 Minimal padding inside ListTile
                          leading: person.avatar != null
                              ? Image.network(
                                  'https://commercebook.site/${person.avatar}',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover)
                              : const Icon(Icons.person),
                          title: Text(person.name, style: ts2),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(person.phone, style: ts2),
                              Text(person.email ?? 'N/A', style: ts2),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ///edit and delete pop up.
  Future<dynamic> editDeleteDiolog(BuildContext context, String billPersonId) {
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
                            EditBillPerson(billPersonId: billPersonId),
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
                    _showDeleteDialog(context, billPersonId);
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
  void _showDeleteDialog(BuildContext context, String billPersonId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Bill Person',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Bill Person?',
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
                  Provider.of<BillPersonProvider>(context, listen: false);

              bool success = await provider.deleteBillPerson(billPersonId);

              Navigator.of(context).pop(); // Close dialog

              if (success) {
                await provider.fetchBillPersons(); // ✅ Reload updated list

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Bill Person deleted successfully.'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(provider.errorMessage),
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