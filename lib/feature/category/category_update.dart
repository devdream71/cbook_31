import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';

class UpdateCategory extends StatefulWidget {
  final int categoryId;

  const UpdateCategory({super.key, required this.categoryId});

  @override
  State<UpdateCategory> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  final TextEditingController _nameController = TextEditingController();
  String selectedStatus = "1";
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryData() async {
    try {
      debugPrint('🔍 Loading category data for ID: ${widget.categoryId}');
      
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final category = await provider.fetchCategoryById(widget.categoryId);
      
      debugPrint('🔍 Received category data: $category');
      
      if (category != null) {
        debugPrint('🔍 Category name: ${category.name}');
        debugPrint('🔍 Category status: ${category.status}');
        
        setState(() {
          _nameController.text = category.name;
          selectedStatus = category.status.toString();
          isLoading = false;
          errorMessage = null;
        });
        
        debugPrint('🔍 Text field updated with: ${_nameController.text}');
      } else {
        debugPrint('❌ Category data is null');
        setState(() {
          isLoading = false;
          errorMessage = 'Category not found';
        });
      }
    } catch (e) {
      debugPrint('💥 Error loading category data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load category data: $e';
      });
    }
  }

  void _updateCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Updating category...'),
          ],
        ),
      ),
    );

    try {
      final provider = Provider.of<CategoryProvider>(context, listen: false);

      debugPrint('🚀 Updating category with:');
      debugPrint('🚀 ID: ${widget.categoryId}');
      debugPrint('🚀 Name: ${_nameController.text.trim()}');
      debugPrint('🚀 Status: $selectedStatus');

      final success = await provider.updateCategory(
        id: widget.categoryId,
        name: _nameController.text.trim(),
        status: selectedStatus,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (!mounted) return;

      if (success) {
        debugPrint('✅ Category updated successfully');
        
        // Refresh the categories list
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

        Navigator.pop(context, true); // Return success flag
      } else {
        debugPrint('❌ Category update failed');
        
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
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      debugPrint('💥 Exception during update: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: $e",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        ),
       
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading category data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade300),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadCategoryData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 

                AddSalesFormfield(
                  labelText: 'Enter Category Name',
                  height: 40,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Category name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                 
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Update button
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
              child: const Text(
                "Update Category",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
