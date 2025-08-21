import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../feature/tax/provider/tax_provider.dart';

class TaxEdit extends StatefulWidget {
  final int taxId;
  const TaxEdit({super.key, required this.taxId});

  @override
  State<TaxEdit> createState() => _TaxEditState();
}

class _TaxEditState extends State<TaxEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();
  String selectedStatus = "1";
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTaxById();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  Future<void> fetchTaxById() async {
    try {
      debugPrint('🔍 Fetching tax data for ID: ${widget.taxId}');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      // ✅ Use proper URL construction
      final url = Uri.parse('${AppUrl.baseurl}tax/edit/${widget.taxId}');
      debugPrint('🔍 API URL: $url');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint('🔍 Response Status: ${response.statusCode}');
      debugPrint('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('🔍 Parsed Data: $data');
        
        // ✅ Check if response has success field
        if (data['success'] == true && data['data'] != null) {
          final tax = data['data'];
          
          debugPrint('🔍 Tax data: $tax');
          
          setState(() {
            _nameController.text = tax['name']?.toString() ?? '';
            _percentController.text = tax['percent']?.toString() ?? '';
            selectedStatus = tax['status']?.toString() ?? '1';
            isLoading = false;
            errorMessage = null;
          });
          
          debugPrint('✅ Tax data loaded successfully');
          debugPrint('✅ Name: ${_nameController.text}');
          debugPrint('✅ Percent: ${_percentController.text}');
          debugPrint('✅ Status: $selectedStatus');
        } else {
          debugPrint('❌ API returned success=false or null data');
          setState(() {
            isLoading = false;
            errorMessage = 'Invalid response from server';
          });
        }
      } else {
        debugPrint("❌ HTTP Error: ${response.statusCode}");
        debugPrint("❌ Error body: ${response.body}");
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch tax details. Status: ${response.statusCode}';
        });
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Exception fetching tax: $e");
      debugPrint("💥 Stack trace: $stackTrace");
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _percentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Updating tax...'),
          ],
        ),
      ),
    );

    try {
      final provider = Provider.of<TaxProvider>(context, listen: false);

      debugPrint('🚀 Updating tax with:');
      debugPrint('🚀 ID: ${widget.taxId}');
      debugPrint('🚀 Name: ${_nameController.text.trim()}');
      debugPrint('🚀 Percent: ${_percentController.text.trim()}');
      debugPrint('🚀 Status: $selectedStatus');

      final success = await provider.updateTax(
        taxId: widget.taxId,
        name: _nameController.text.trim(),
        percent: _percentController.text.trim(),
        status: selectedStatus,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        if (success) {
          debugPrint('✅ Tax updated successfully');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tax updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true); // Return success flag
        } else {
          debugPrint('❌ Tax update failed');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage.isNotEmpty 
                  ? provider.errorMessage 
                  : "Failed to update tax"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      debugPrint('💥 Exception during update: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
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
        title: const Text(
          'Edit Tax',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Add refresh button
          IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              fetchTaxById();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
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
            Text('Loading tax data...'),
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
                fetchTaxById();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
               

                AddSalesFormfield(
                  height: 40,
                  controller: _nameController,
                  labelText: "Tax Name",
                ),
                const SizedBox(height: 10),
                
                AddSalesFormfield(
                  height: 40,
                  controller: _percentController,
                  labelText: "Percent",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                
              
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Update Tax",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}