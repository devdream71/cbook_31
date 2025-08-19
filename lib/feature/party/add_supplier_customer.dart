import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/price_option_selector_customer.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list_provider.dart';

import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSupplierCustomer extends StatefulWidget {
  const AddSupplierCustomer({super.key});

  @override
  State<AddSupplierCustomer> createState() => _AddSupplierCustomerState();
}

class _AddSupplierCustomerState extends State<AddSupplierCustomer> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _proprietorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _opiningBanglaceController = TextEditingController();

  String _selectedPrice = "";
  bool _isChecked = false;
  String selectedStatus = "1";
  bool isLoading = false;

  
  ///save customer
  void _saveCustomer() async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final status = selectedStatus;
    final proprietorName = _proprietorController.text.trim();
    final openingBalance = _opiningBanglaceController.text.trim();
    final levelType = _isChecked ? _selectedPrice : "";
    final level = _isChecked ? "1" : "";

    if (name.isNotEmpty &&
        proprietorName.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        openingBalance.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await customerProvider.createCustomer(
        name: name,
        email: email,
        phone: phone,
        address: address,
        status: status,
        proprietorName: proprietorName,
        openingBalance: openingBalance,
        levelType: levelType,
        level: level,
      );

      setState(() {
        isLoading = false;
      });

      if (customerProvider.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Customer Created", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        // Clear all fields
        _nameController.clear();
        _proprietorController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _statusController.clear();
        _opiningBanglaceController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(customerProvider.errorMessage)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill all required fields."),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    ///fetch supplies
    Future.microtask(() =>
        Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers());

    ///fetch customer
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Column(
            children: [
              Text(
                'Add new party',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xffdddefa)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///Add customer
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CustomerCreate()),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          //border: Border.all(color: Colors.green),
                          //borderRadius: BorderRadius.circular(6)
                          ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Add new customer",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  ///add supplier
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SuppliersCreate()),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          //border: Border.all(color: Colors.green),
                          //borderRadius: BorderRadius.circular(6)
                          ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.face,
                              size: 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Add New Supplier",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            // _buildFieldLabel("Customer Name", textTheme, colorScheme),

            AddSalesFormfield(
              label: "Enter Customer Name",
              controller: _nameController,
              //validator: _validateRequired,
            ),

            const SizedBox(
              height: 12,
            ),

            AddSalesFormfield(
              label: "Enter Proprietor Name",
              controller: _proprietorController,
              //validator: _validateRequired,
            ),

            /// Price Level Selector
            PriceOptionSelectorCustomer(
              title: "Price Level",
              selectedPrice: _selectedPrice,
              onPriceChanged: (value) {
                // setState(() {
                //   _selectedPrice = value!;
                // });
                setState(() {
                  // Convert "Dealer Price" back to "dealer_price"
                  _selectedPrice =
                      value?.replaceAll(" ", "_").toLowerCase() ?? "";
                });
              },
              isChecked: _isChecked,
              onCheckedChanged: (value) {
                setState(() {
                  _isChecked = value;
                  if (!value)
                    _selectedPrice = ""; // Reset dropdown if unchecked
                });
              },
            ),

            const SizedBox(
              height: 12,
            ),

            AddSalesFormfield(
              label: "Enter Email",
              controller: _emailController,
              //validator: _validateEmail,
            ),

            const SizedBox(
              height: 12,
            ),

            AddSalesFormfield(
              label: "Enter Phone",
              controller: _phoneController,
              //validator: _validatePhone,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(
              height: 12,
            ),

            AddSalesFormfield(
              label: "Enter Address",
              controller: _addressController,
              //validator: _validateRequired,
            ),

            const SizedBox(
              height: 12,
            ),

            AddSalesFormfield(
              label: "Enter Opening Balance",
              controller: _opiningBanglaceController,
              //validator: _validateRequired,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              "Status",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),

            SizedBox(
              width: double.infinity,
              child: CustomDropdownTwo(
                items: const ["Active", "Inactive"], // Display labels
                hint: '', //Select status
                width: double.infinity,
                height: 30,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = (value == "Active")
                        ? "1"
                        : "0"; // ✅ Convert label to 1 or 0
                  });
                  debugPrint(selectedStatus);
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Save Customer",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ));
  }
}
