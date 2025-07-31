import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/unit/provider/unit_provider.dart';
import 'package:cbook_dt/feature/unit/unit_list.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddUnit extends StatefulWidget {
  const AddUnit({super.key});

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController symbolController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  String selectedStatus = "1"; // Default status

  void _saveUnit() {
    final unitProvider = Provider.of<UnitDTProvider>(context, listen: false);
    final name = nameController.text.trim();
    final symbol = symbolController.text.trim();

    if (name.isNotEmpty && symbol.isNotEmpty) {
      unitProvider.addUnit(name, symbol, selectedStatus).then((_) {
        if (!mounted)
          return; // ✅ Check if widget is still active before using context

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unit added successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UnitListView()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Please enter Unit Name and Symbol.")),
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
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Add Unit",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vPad10,
                    AddSalesFormfield(
                      labelText: "Name",
                      height: 40,
                      controller: nameController,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    AddSalesFormfield(
                      labelText: 'Symbol',
                      height: 40,
                      controller: symbolController,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    // const Text(
                    //   "Status",
                    //   style: TextStyle(
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 12),
                    // ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: CustomDropdownTwo(
                    //     items: const ["Active", "Inactive"], // Display labels
                    //     hint: '', //Select status
                    //     width: double.infinity,
                    //     height: 40,
                    //     value: selectedStatus == "1"
                    //         ? "Active"
                    //         : "Inactive", // ✅ reflect selection
                    //     onChanged: (value) {
                    //       setState(() {
                    //         selectedStatus = (value == "Active")
                    //             ? "1"
                    //             : "0"; // ✅ Convert label to 1 or 0
                    //       });
                    //       debugPrint(selectedStatus);
                    //     },
                    //   ),
                    // ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveUnit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Unit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

               const SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }
}
