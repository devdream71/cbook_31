import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

class CreateSubCategory extends StatefulWidget {
  const CreateSubCategory({super.key});

  @override
  State<CreateSubCategory> createState() => _CreateSubCategoryState();
}

class _CreateSubCategoryState extends State<CreateSubCategory> {
  final TextEditingController _nameController = TextEditingController();
  String selectedCategory = "";
  String selectedStatus = "1";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
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
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Create Sub Category",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            if (categoryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8 + 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddSalesFormfield(
                          labelText: 'Subcategory Name',
                          height: 40,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),

                        // Category Dropdown
                        SizedBox(
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: categoryProvider.categories
                                .map((category) => category.name)
                                .toList(),
                            width: double.infinity,
                            labelText: 'Category',
                            height: 40,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // const Text(
                        //   "Status",
                        //   style: TextStyle(
                        //       color: Colors.black,
                        //       fontWeight: FontWeight.w600,
                        //       fontSize: 12),
                        // ),

                        // // Status Dropdown
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: CustomDropdownTwo(
                        //     items: const ["Active", "Inactive"],
                        //     hint: '', //Select status
                        //     width: double.infinity,
                        //     height: 40,
                        //     onChanged: (value) {
                        //       setState(() {
                        //         selectedStatus =
                        //             (value == "Active") ? "1" : "0";
                        //       });
                        //     },
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty &&
                          selectedCategory.isNotEmpty) {
                        final category = categoryProvider.categories
                            .firstWhere((cat) => cat.name == selectedCategory);
                        final categoryId = category.id;

                        await categoryProvider.createSubCategory(
                          _nameController.text,
                          selectedStatus,
                          categoryId,
                          context,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                                "Please fill subcategory name & selected a category."),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save Sub Category",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(
                  height: 50,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
