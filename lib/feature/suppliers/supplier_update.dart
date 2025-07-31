import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/suppliers/model/suppliers_creat.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SupplierUpdate extends StatefulWidget {
  final SupplierData supplier;

  const SupplierUpdate({
    super.key,
    required this.supplier,
  });

  @override
  SupplierUpdateState createState() => SupplierUpdateState();
}

class SupplierUpdateState extends State<SupplierUpdate> {
  late TextEditingController nameController;
  late TextEditingController proprietorController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController idController;

  final TextEditingController _statusController = TextEditingController();

  String selectedStatus = "1";

  @override
  void initState() {
    super.initState();

    // Debugging: Ensure supplier data is passed correctly
    debugPrint("Supplier Data:");
    debugPrint("ID: ${widget.supplier.id}"); // Make sure the ID is correct here
    debugPrint("Name: ${widget.supplier.name}");
    debugPrint("Proprietor Name: ${widget.supplier.proprietorName}");
    debugPrint("Email: ${widget.supplier.email}");
    debugPrint("Phone: ${widget.supplier.phone}");
    debugPrint("Address: ${widget.supplier.address}");
    debugPrint("Status: ${widget.supplier.status}");

    // Initialize controllers with the passed supplier data
    nameController = TextEditingController(text: widget.supplier.name);
    proprietorController =
        TextEditingController(text: widget.supplier.proprietorName);
    emailController = TextEditingController(text: widget.supplier.email);
    phoneController = TextEditingController(text: widget.supplier.phone);
    addressController = TextEditingController(text: widget.supplier.address);
    idController = TextEditingController(text: widget.supplier.id.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    proprietorController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(title: const Text("Update Supplier")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddSalesFormfield(
              label: "Supplier Name",
              controller: nameController,
              //validator: _validateRequired,
            ),
            AddSalesFormfield(
              label: "Proprietor Name",
              controller: proprietorController,
              //validator: _validateRequired,
            ),
            AddSalesFormfield(
              label: "Email",
              controller: emailController,
              //validator: _validateRequired,
            ),
            AddSalesFormfield(
              label: "Phone",
              controller: phoneController,
              keyboardType: TextInputType.number,
              //validator: _validateRequired,
            ),
            AddSalesFormfield(
              label: "Address",
              controller: addressController,
              //validator: _validateRequired,
            ),
            const SizedBox(height: 20),

            const Text("Status", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),),
             
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
                onPressed: () async {
                  final supplierProvider =
                      Provider.of<SupplierProvider>(context, listen: false);

                  // Ensure valid supplier ID before update
                  int supplierId = widget.supplier.id;
                  if (supplierId == 0) {
                    // Handle the case where the supplier ID is 0
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid Supplier ID")));
                    return;
                  }

                  debugPrint("Updating Supplier with ID: $supplierId");

                  await supplierProvider.updateSupplier(
                    context: context,
                    id: supplierId.toString(),
                    name: nameController.text,
                    proprietorName: proprietorController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    status: _statusController.text,
                  );
                  if (supplierProvider.errorMessage.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "Supplier updated successfully",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Error: ${supplierProvider.errorMessage}, ",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Supplier",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

             const SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
