import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SuppliersCreate extends StatefulWidget {
  const SuppliersCreate({super.key});

  @override
  State<SuppliersCreate> createState() => _SuppliersCreateState();
}

class _SuppliersCreateState extends State<SuppliersCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _proprietorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _opiningBanglaceController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String selectedStatus = "1"; // Default status

  final ImagePicker _picker = ImagePicker();

  final ImagePicker _picker2 = ImagePicker();

  XFile? _imageFile;

  XFile? _imageFile2;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _pickImage2(ImageSource source) async {
    final XFile? pickedFile2 = await _picker2.pickImage(source: source);

    if (pickedFile2 != null) {
      setState(() {
        _imageFile2 = pickedFile2;
      });
    }
  }

  void _saveSupplier() async {
    final supplierProvider =
        Provider.of<SupplierProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final status = selectedStatus;
    final proprietorName = _proprietorController.text.trim();
    final openingBalance = _opiningBanglaceController.text.trim();

    // ✅ Basic required field check
    if (name.isNotEmpty &&
        proprietorName.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        openingBalance.isNotEmpty) {

      await supplierProvider.createSupplier(
        name: name,
        email: email,
        phone: phone,
        address: address,
        status: status,
        proprietorName: proprietorName,
        openingBalance: openingBalance,
        avatarImage: _imageFile,
      );

      if (supplierProvider.errorMessage.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Supplier Create",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Clear form
        _nameController.clear();
        _proprietorController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _opiningBanglaceController.clear();
        _statusController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              supplierProvider.errorMessage,
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all required fields.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = Provider.of<SupplierProvider>(context);

    final textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Create Supplier",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AddSalesFormfield(
                labelText: "Supplier Name",
                height: 40,

                controller: _nameController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                labelText: "Proprietor Name",
                height: 40,

                controller: _proprietorController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                labelText: "Phone",
                height: 40,

                controller: _phoneController,
                keyboardType: TextInputType.number,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                labelText: "Email",
                height: 40,

                controller: _emailController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                labelText: "Address",
                height: 40,

                controller: _addressController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      keyboardType: TextInputType.number,
                      labelText: "Opening Balance",
                      height: 40,

                      controller: _opiningBanglaceController,
                      //validator: _validateRequired,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Background color
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                            border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.5), // Border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.1), // Light shadow
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1), // Shadow position
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => supplierProvider.pickDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                hintText: "Bill Date",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 10,
                                ),
                                border: InputBorder
                                    .none, // Remove default underline
                              ),
                              child: Text(
                                supplierProvider.formattedDate.isNotEmpty
                                    ? supplierProvider.formattedDate
                                    : "No Date Provided",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ///business logoi
                  Column(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: _imageFile != null
                                      ? FileImage(File(_imageFile!.path))
                                      : const AssetImage(
                                          "assets/image/image_upload_blue.png"),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  _showImageSourceActionSheet(context);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "Upload Image ",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),

                  //company/ customer
                  // Column(
                  //   children: [
                  //     Center(
                  //       child: Stack(
                  //         alignment: Alignment.bottomRight,
                  //         children: [
                  //           Container(
                  //             width: 90,
                  //             height: 90,
                  //             decoration: BoxDecoration(
                  //               color: Colors.green[100],
                  //               borderRadius: BorderRadius.circular(8),
                  //               image: DecorationImage(
                  //                 image: _imageFile2 != null
                  //                     ? FileImage(File(_imageFile2!.path))
                  //                     : const AssetImage(
                  //                         "assets/image/image_upload_green.png",
                  //                       ),
                  //                 fit: BoxFit.fitWidth,
                  //               ),
                  //             ),
                  //           ),
                  //           Positioned(
                  //             bottom: 4,
                  //             right: 4,
                  //             child: GestureDetector(
                  //               onTap: () {
                  //                 _showImageSourceActionSheet2(context);
                  //               },
                  //               child: Container(
                  //                 decoration: const BoxDecoration(
                  //                   shape: BoxShape.circle,
                  //                   color: Colors.white,
                  //                 ),
                  //                 padding: const EdgeInsets.all(6),
                  //                 child: const Icon(
                  //                   Icons.camera_alt,
                  //                   size: 20,
                  //                   color: Colors.black,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     const Text(
                  //       "Company/Customer Logo",
                  //       style: TextStyle(color: Colors.black, fontSize: 13),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSupplier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Save Supplier",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildFieldLabel(
      String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceActionSheet2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage2(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage2(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
