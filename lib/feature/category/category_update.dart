import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/category/item_category_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';

class UpdateCategory extends StatefulWidget {
  final int categoryId;

  const UpdateCategory({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<UpdateCategory> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  final TextEditingController _nameController = TextEditingController();
  String selectedStatus = "1";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final category = await provider.fetchCategoryById(widget.categoryId);
    if (category != null) {
      _nameController.text = category.name;
      selectedStatus = category.status.toString();
    }
    setState(() => isLoading = false);
  }

  void _updateCategory() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);

    final success = await provider.updateCategory(
      id: widget.categoryId,
      name: _nameController.text.trim(),
      status: selectedStatus,
    );

    if (!mounted) return; // ✅ Prevent further execution if widget is disposed

    if (success) {
      await provider.fetchCategories();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Category updated successfully!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ItemCategoryView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to update category",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
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
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Update Category",
            style: TextStyle(color: Colors.yellow),
          )),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddSalesFormfield(
                            labelText: 'Enter Category Name',
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
                          //     items: const ["Active", "Inactive"],
                          //     hint: '', //Select status
                          //     width: double.infinity,
                          //     height: 40,
                          //     onChanged: (value) {
                          //       setState(() {
                          //         selectedStatus = value == "Active" ? "1" : "0";
                          //       });
                          //     },
                          //   ),
                          // ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  ///save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Update Category",
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
