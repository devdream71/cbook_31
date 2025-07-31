import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/category/model/category_list.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/category/sub_category/create_sub_category.dart';
import 'package:cbook_dt/feature/category/sub_category/edit_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemSubCategoryView extends StatefulWidget {
  const ItemSubCategoryView({super.key});

  @override
  _ItemSubCategoryViewState createState() => _ItemSubCategoryViewState();
}

class _ItemSubCategoryViewState extends State<ItemSubCategoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CategoryProvider>();
      await provider.fetchCategories();
      await provider.fetchSubCategories();
    });
  }

  // void _confirmDelete(BuildContext context, int subcategoryId) async {
  //   final confirm = await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Confirm Delete"),
  //         content: const Text(
  //           "Are you sure you want to delete this category?",
  //           style: TextStyle(color: Colors.black),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context, true);
  //             },
  //             child: const Text("Delete", style: TextStyle(color: Colors.red)),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirm == true) {
  //     await context.read<CategoryProvider>().deleteSubCategory(subcategoryId);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Category Delete successfully!"),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   }
  // }

  String getCategoryName(BuildContext context, int categoryId) {
    final categories = context.read<CategoryProvider>().categories;
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => ItemCategoryModel(
        id: 0,
        userId: 0,
        name: "Unknown Category",
        status: 1,
        deletedAt: null,
        createdAt: '',
        updatedAt: '',
      ),
    );
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        //centerTitle: true,
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Item Subcategories",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateSubCategory()));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    'Add Sub Cat ',
                    style: TextStyle(color: Colors.yellow, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.subcategories.isEmpty) {
                    return const Center(
                        child: Text(
                      "No subcategories found",
                      style: TextStyle(color: Colors.black),
                    ));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = provider.subcategories[index];
                      final categoryName =
                          getCategoryName(context, subcategory.itemCategoryId);

                      final subcategoryID = provider.subcategories[index].id;

                      return InkWell(
                        onLongPress: () {
                          editDeleteDialog(context, subcategoryID.toString());
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // 🔁 No rounded corners
                            side: BorderSide(
                                color: Colors.grey.shade300), // ✅ Border
                          ),
                          elevation: 0,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 15,
                              child: Text("${index + 1}"),
                            ),
                            contentPadding: const EdgeInsets.only(left: 16),
                            title: Text(
                              subcategory.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            //subtitle: Text("Category ID: ${subcategory.itemCategoryId}"),
                            subtitle: Text(
                              "Category: $categoryName",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87),
                            ),

                            
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> editDeleteDialog(
    BuildContext context,
    String subcategoryID,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();

                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateSubCategory(
                              subcategoryId: int.tryParse(subcategoryID)),
                        ),
                      );
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, subcategoryID);
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

  void _showDeleteDialog(BuildContext context, String subcategoryID) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete sub-Category',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this sub-Category?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider =
                  Provider.of<CategoryProvider>(context, listen: false);
              // bool isDeleted = await provider.deleteUnit(int.parse(unitId));

              bool isDeleted =
                  await provider.deleteSubCategory(int.parse(subcategoryID));

              
    

              Navigator.of(context).pop(); // Close confirm dialog

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'sub-Category deleted successfully!',
                      style: TextStyle(color: colorScheme.primary),
                    ),       
                    backgroundColor: Colors.green,
                  ),
                );
                await provider.fetchCategories(); // Refresh list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Failed to delete sub-Category',
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
