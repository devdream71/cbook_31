import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/category/category_update.dart';
import 'package:cbook_dt/feature/category/create_category.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemCategoryView extends StatefulWidget {
  const ItemCategoryView({super.key});

  @override
  ItemCategoryViewState createState() => ItemCategoryViewState();
}

class ItemCategoryViewState extends State<ItemCategoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        //centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Item Categories",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateCategory()));
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
                    'Add Categories',
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

                  if (provider.categories.isEmpty) {
                    return const Center(
                        child: Text(
                      "No categories found",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];

                      final categoryId = provider.categories[index].id;

                      return InkWell(
                        onLongPress: () {
                          editDeleteDialog(context, categoryId.toString());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            elevation: 0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(left: 16),
                              leading: CircleAvatar(
                                radius: 15,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(category.name,
                                  style: const TextStyle(fontSize: 12)),
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
    String categoryId,
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
                          builder: (context) =>
                              UpdateCategory(categoryId: int.parse(categoryId)),
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
                    _showDeleteDialog(context, categoryId);
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

  void _showDeleteDialog(BuildContext context, String categoryId) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Category',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Category?',
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
                  await provider.deleteCategory(int.parse(categoryId));

              Navigator.of(context).pop(); // Close confirm dialog

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Category deleted successfully!',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    //backgroundColor: ,
                    backgroundColor: Colors.green,
                  ),
                );
                await provider.fetchCategories(); // Refresh list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Failed to delete Category',
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
