import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/price_option_selector_customer.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CustomerUpdate extends StatefulWidget {
  final CustomerData customer;

  const CustomerUpdate({
    super.key,
    required this.customer,
  });

  @override
  CustomerUpdateState createState() => CustomerUpdateState();
}

class CustomerUpdateState extends State<CustomerUpdate> {
  late TextEditingController nameController;
  late TextEditingController proprietorController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController idController;

  final TextEditingController _statusController = TextEditingController();

  // ✅ Image picker functionality
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _existingImage;

  @override
  void initState() {
    super.initState();

    // Debugging: Ensure customer data is passed correctly
    debugPrint("Customer Data:");
    debugPrint("ID: ${widget.customer.id}");
    debugPrint("Name: ${widget.customer.name}");
    debugPrint("Proprietor Name: ${widget.customer.proprietorName}");
    debugPrint("Email: ${widget.customer.email}");
    debugPrint("Phone: ${widget.customer.phone}");
    debugPrint("Address: ${widget.customer.address}");
    //debugPrint("Avatar: ${widget.customer.avatar}");
    debugPrint("Status: ${widget.customer.status}");

    // Initialize controllers with the passed customer data
    nameController = TextEditingController(text: widget.customer.name);
    proprietorController =
        TextEditingController(text: widget.customer.proprietorName ?? '');
    emailController = TextEditingController(text: widget.customer.email ?? '');
    phoneController = TextEditingController(text: widget.customer.phone ?? '');
    addressController = TextEditingController(text: widget.customer.address ?? '');
    idController = TextEditingController(text: widget.customer.id.toString());

    // ✅ Set existing image
    _existingImage = widget.customer.avatar;

    // Check if customer has a level (fixing the error)
    if (widget.customer.level != null && widget.customer.level! > 0) {
      _selectedPrice =
          widget.customer.levelType ?? ""; // Assign existing levelType
      _isChecked = true; // Check the checkbox if level exists
    } else {
      _selectedPrice = ""; // Reset dropdown if no level
      _isChecked = false; // Uncheck checkbox
    }
  }

  String _selectedPrice = "";
  bool _isChecked = false;
  String selectedStatus = "1";

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

  // ✅ Image picker methods
  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
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
              if (_imageFile != null || (_existingImage != null && _existingImage!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageFile = null;
                      _existingImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text("Update Party",
            style: TextStyle(color: Colors.yellow, fontSize: 14)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Image picker section
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.green[100],
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _imageFile != null
                                  ? FileImage(File(_imageFile!.path))
                                  : (_existingImage != null && _existingImage!.isNotEmpty
                                      ? NetworkImage("https://commercebook.site/$_existingImage")
                                      : const AssetImage('assets/image/image_color.png'))
                                  as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showImageSourceActionSheet(context),
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
                    const SizedBox(height: 20),

                    AddSalesFormfield(
                      height: 40,
                      labelText: "Party Name",
                      controller: nameController,
                    ),

                    const SizedBox(height: 12),

                    AddSalesFormfield(
                      height: 40,
                      labelText: 'Proprietor Name',
                      controller: proprietorController,
                    ),

                    const SizedBox(height: 12),

                    // Conditionally render the PriceOptionSelectorCustomer widget
                    PriceOptionSelectorCustomer(
                      title: "Price Level",
                      selectedPrice: _selectedPrice,
                      onPriceChanged: (value) {
                        setState(() {
                          _selectedPrice =
                              value?.replaceAll(" ", "_").toLowerCase() ?? "";
                        });
                      },
                      isChecked: _isChecked,
                      onCheckedChanged: (value) {
                        setState(() {
                          _isChecked = value;
                          if (!value) _selectedPrice = ""; // Reset dropdown if unchecked
                        });
                      },
                    ),

                    AddSalesFormfield(
                      height: 40,
                      labelText: "Email",
                      controller: emailController,
                    ),

                    const SizedBox(height: 12),

                    AddSalesFormfield(
                      height: 40,
                      labelText: "Phone",
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    AddSalesFormfield(
                      height: 40,
                      labelText: 'Address',
                      controller: addressController,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ✅ Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Updating customer...'),
                        ],
                      ),
                    ),
                  );

                  try {
                    final customerProvider =
                        Provider.of<CustomerProvider>(context, listen: false);

                    int customerId = widget.customer.id;
                    if (customerId == 0) {
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid Party ID")),
                      );
                      return;
                    }

                    String level = _isChecked ? "1" : "0"; // If checked, level is "1"
                    String levelType = _isChecked ? _selectedPrice : ""; // Assign only if level is 1

                    // ✅ Call the update method with image
                    await customerProvider.updateCustomerWithImage(
                      context: context,
                      id: customerId.toString(),
                      name: nameController.text,
                      proprietorName: proprietorController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      status: selectedStatus,
                      level: level,
                      levelType: levelType,
                      imageFile: _imageFile != null ? File(_imageFile!.path) : null,
                    );

                    // Close loading dialog
                    if (mounted) Navigator.of(context).pop();

                    if (mounted) {
                      if (customerProvider.errorMessage.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                            content: const Text(
                              "Party updated successfully",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppColors.primaryColor,
                          ),
                        );
                        Navigator.of(context).pop(true); // Return success
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${customerProvider.errorMessage}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Close loading dialog
                    if (mounted) Navigator.of(context).pop();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Party",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

 