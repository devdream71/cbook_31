import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';

class UpdateSubCategory extends StatefulWidget {
  final int? subcategoryId;

  const UpdateSubCategory({required this.subcategoryId, super.key});

  @override
  State<UpdateSubCategory> createState() => _UpdateSubCategoryState();
}

class _UpdateSubCategoryState extends State<UpdateSubCategory> {
  final TextEditingController _nameController = TextEditingController();
  int? selectedCategoryId;
  String? selectedCategoryName;
  String selectedStatus = "1";
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);

    await provider.fetchCategories();
    await provider.fetchSubcategoryDetails(widget.subcategoryId!);

    final subcategory = provider.editSubcategory;

    if (subcategory != null && provider.categories.isNotEmpty) {
      final selectedCategory = provider.categories.firstWhere(
        (cat) => cat.id == subcategory.categoryId,
        orElse: () => provider.categories.first,
      );
      setState(() {
        _nameController.text = subcategory.name;
        selectedStatus = subcategory.status.toString();
        selectedCategoryId = selectedCategory.id;
        selectedCategoryName = selectedCategory.name;
        _isDataLoaded = true;
      });
    } else {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Update Sub Category",
            style: TextStyle(color: Colors.yellow),
          )),
      body: !_isDataLoaded
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
              ? const Center(child: Text("No categories found"))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AddSalesFormfield(
                                height: 40,
                                labelText: 'Subcategory Name',
                                controller: _nameController,
                              ),
                              const SizedBox(height: 12),

                              const SizedBox(height: 5),
                              SizedBox(
                                width: double.infinity,
                                child: CustomDropdownTwo(
                                  items: provider.categories
                                      .map((cat) => cat.name)
                                      .toList(),
                                  labelText: "Select Category",
                                  width: double.infinity,
                                  height: 40,
                                  selectedItem: selectedCategoryName,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategoryName = value;
                                      selectedCategoryId = provider.categories
                                          .firstWhere(
                                              (cat) => cat.name == value)
                                          .id;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // const Text("Status",
                              //     style: TextStyle(
                              //         color: Colors.black, fontSize: 12)),
                              // const SizedBox(height: 5),
                              // SizedBox(
                              //   width: double.infinity,
                              //   child: CustomDropdownTwo(
                              //     items: const ["Active", "Inactive"],
                              //     hint: "Select Status",
                              //     width: double.infinity,
                              //     height: 40,
                              //     selectedItem: selectedStatus == "1"
                              //         ? "Active"
                              //         : "Inactive",
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_nameController.text.isNotEmpty &&
                                selectedCategoryId != null) {
                              await provider.updateSubCategory(
                                id: widget.subcategoryId!,
                                name: _nameController.text,
                                status: selectedStatus,
                                context: context,
                                itemCategoryId: selectedCategoryId!,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please fill in all fields")),
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
                          child: const Text("Update Sub Category",
                              style: TextStyle(color: Colors.white)),
                        ),
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
