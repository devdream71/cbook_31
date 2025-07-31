import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCategory extends StatefulWidget {
  const CreateCategory({super.key});

  @override
  State<CreateCategory> createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategory> {
  final TextEditingController _nameController = TextEditingController();
  String selectedStatus = "1";

  void _saveCategory() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final name = _nameController.text.trim();

    if (name.isNotEmpty) {
      categoryProvider.createCategory(name, selectedStatus).then((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Category added successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        categoryProvider.fetchCategories();

        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Please enter category name.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Category", //create
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddSalesFormfield(
                    labelText: 'Category Name',
                    height: 40,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 12),
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
                  //     onChanged: (value) {
                  //       setState(() {
                  //         selectedStatus = (value == "Active") ? "1" : "0";
                  //       });
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            ///Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: categoryProvider.isAdding ? null : _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: categoryProvider.isAdding
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Category",
                        style: TextStyle(color: Colors.white)),
              ),
            ),

             const SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
