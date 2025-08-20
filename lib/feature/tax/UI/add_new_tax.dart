import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewTax extends StatefulWidget {
  const AddNewTax({super.key});

  @override
  State<AddNewTax> createState() => _AddNewTaxState();
}

class _AddNewTaxState extends State<AddNewTax> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _percentanceController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.clear();
    _percentanceController.clear();
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
          'Add New Tax',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ///name
                  AddSalesFormfield(
                    labelText: "Tax Name",
                    height: 40,
                    label: "",
                    controller: _nameController,
                    //validator: _validateRequired,
                  ),

                  ///percentance
                  AddSalesFormfield(
                    labelText: "Tax Percentance",
                    height: 40,
                    label: "",
                    controller: _percentanceController,
                    //validator: _validateRequired,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userId = prefs.getInt('user_id')?.toString();

                    if (userId == null) {
                      debugPrint("User ID is null");
                      return;
                    }

                    final name = _nameController.text.trim();
                    final percent = _percentanceController.text.trim();
                    // final percentInt = int.tryParse(percent);
                    final percentDouble = double.tryParse(percent);

                    // ✅ Better validation
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter tax name")),
                      );
                      return;
                    }

                    if (percent.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please enter tax percentage")),
                      );
                      return;
                    }

                    if (percentDouble == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Please enter a valid number for percentage")),
                      );
                      return;
                    }

                    // ✅ Now safe to use percentInt without null check operator
                    final taxProvider =
                        Provider.of<TaxProvider>(context, listen: false);

                    await taxProvider.createTax(
                      userId: int.parse(userId),
                      name: name,
                      percent: percentDouble, // ✅ No need for ! operator
                      status: 1,
                    );

                    Navigator.pop(context, true);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Successfully, Tax Create.")),
                    );
                  },

                  // onPressed: () async {
                  //   SharedPreferences prefs =
                  //       await SharedPreferences.getInstance();
                  //   String? userId = prefs.getInt('user_id')?.toString();

                  //   if (userId == null) {
                  //     debugPrint("User ID is null");
                  //     return;
                  //   }

                  //   final name = _nameController.text.trim();
                  //   final percent = _percentanceController.text.trim();

                  //   final percentInt = int.tryParse(percent);

                  //   if (name.isNotEmpty && percent.isNotEmpty) {
                  //     final taxProvider =
                  //         Provider.of<TaxProvider>(context, listen: false);

                  //     await taxProvider.createTax(
                  //       userId: int.parse(userId),
                  //       name: name,
                  //       percent: percentInt!,
                  //       status: 1,
                  //     );
                  //     //Navigator.pop(context); // Optionally pop after saving

                  //    //await taxProvider.fetchTaxes(); //fetchTaxes

                  //    Navigator.pop(context, true);

                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //           backgroundColor: Colors.green,
                  //           content: Text("Successfully, Tax Create.")),
                  //     );
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text("Please fill all fields")),
                  //     );
                  //   }
                  // },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save tax",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
