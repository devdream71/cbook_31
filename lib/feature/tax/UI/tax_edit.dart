import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../feature/tax/provider/tax_provider.dart'; // adjust path if needed

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

  @override
  void initState() {
    super.initState();
    fetchTaxById();
  }

  Future<void> fetchTaxById() async {
    final url =
        Uri.parse("https://commercebook.site/api/v1/tax/edit/${widget.taxId}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tax = data['data'];

        setState(() {
          _nameController.text = tax['name'] ?? '';
          _percentController.text = tax['percent'] ?? '';
          selectedStatus = tax['status'].toString();
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed to fetch tax details.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching tax: $e");
    }
  }

  Future<void> _submit() async {
    final provider = Provider.of<TaxProvider>(context, listen: false);

    if (_nameController.text.isEmpty || _percentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await provider.updateTax(
      taxId: widget.taxId,
      name: _nameController.text,
      percent: _percentController.text,
      status: selectedStatus,
    );

    if (success) {
      provider.fetchTaxes();

      Navigator.pop(context, true); // go back after successful update

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully, Update the tax"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
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
        title: const Text(
          'Edit Tax',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AddSalesFormfield(
                          height: 40,
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: "Tax Name"),
                        ),
                        const SizedBox(height: 10),
                        AddSalesFormfield(
                          height: 40,
                          controller: _percentController,
                          decoration:
                              const InputDecoration(labelText: "Percent"),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
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
                        //padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Update Tax",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
