import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/price_option_selector_customer.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/party/party_list.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CustomerCreate extends StatefulWidget {
  const CustomerCreate({super.key});

  @override
  State<CustomerCreate> createState() => _CustomerCreateState();
}

class _CustomerCreateState extends State<CustomerCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _proprietorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _individualNameController =
      TextEditingController();

  final TextEditingController _opiningBanglaceController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _selectedPrice = "";
  bool _isChecked = false;

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

  bool isLoading = false;

  String _selectedType = 'Individual'; //Individual

  // Modified _saveCustomer method
  void _saveCustomer() async {
    FocusScope.of(context).unfocus();

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

    if (name.isNotEmpty && proprietorName.isNotEmpty) {
      setState(() {
        isLoading = true; // This will disable the button
      });

      try {
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
          imageFile: _imageFile != null ? File(_imageFile!.path) : null,
          logo: _imageFile2 != null ? File(_imageFile2!.path) : null,
        );

        if (customerProvider.errorMessage.isEmpty) {
          // Success - clear all fields
          _nameController.clear();
          _proprietorController.clear();
          _emailController.clear();
          _phoneController.clear();
          _addressController.clear();
          _statusController.clear();
          _opiningBanglaceController.clear();

          // Reset other form states if needed
          setState(() {
            _imageFile = null;
            _imageFile2 = null;
            _isChecked = false;
            _selectedPrice = "";
            // Reset any other form variables
          });

          // Refresh customer list
          await customerProvider.fetchCustomsr();

          // Navigate back
          Navigator.pop(context);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Customer Created",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Error occurred - show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(customerProvider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle any unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Always re-enable the button
        setState(() {
          isLoading = false;
        });
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

  // void _saveCustomer() async {
  //   // FocusManager.instance.primaryFocus?.unfocus();
  //   FocusScope.of(context).unfocus();

  //   final customerProvider =
  //       Provider.of<CustomerProvider>(context, listen: false);

  //   final name = _nameController.text.trim();
  //   final email = _emailController.text.trim();
  //   final phone = _phoneController.text.trim();
  //   final address = _addressController.text.trim();
  //   final status = selectedStatus;
  //   final proprietorName = _proprietorController.text.trim();
  //   final openingBalance = _opiningBanglaceController.text.trim();
  //   final levelType = _isChecked ? _selectedPrice : "";
  //   final level = _isChecked ? "1" : "";

  //   if (name.isNotEmpty && proprietorName.isNotEmpty

  //       // &&
  //       // phone.isNotEmpty &&
  //       // address.isNotEmpty &&
  //       // openingBalance.isNotEmpty

  //       ) {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     await customerProvider.createCustomer(
  //       name: name,
  //       email: email,
  //       phone: phone ?? '',
  //       address: address ?? '',
  //       status: status,
  //       proprietorName: proprietorName,
  //       openingBalance: openingBalance ?? '',
  //       levelType: levelType,
  //       level: level,
  //       imageFile: _imageFile != null ? File(_imageFile!.path) : null,
  //       logo: _imageFile2 != null ? File(_imageFile2!.path) : null,
  //     );

  //     setState(() {
  //       isLoading = false;
  //     });

  //     if (customerProvider.errorMessage.isEmpty) {
  //       final customerProvider =
  //           Provider.of<CustomerProvider>(context, listen: false);

  //       customerProvider.fetchCustomsr();

  //       ///back to 2 step back.
  //       Navigator.pop(context);
  //       Navigator.pop(context);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content:
  //               Text("Customer Created", style: TextStyle(color: Colors.white)),
  //           backgroundColor: Colors.green,
  //         ),
  //       );

  //       // Clear all fields
  //       _nameController.clear();
  //       _proprietorController.clear();
  //       _emailController.clear();
  //       _phoneController.clear();
  //       _addressController.clear();
  //       _statusController.clear();
  //       _opiningBanglaceController.clear();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(customerProvider.errorMessage)),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         backgroundColor: Colors.red,
  //         content: Text("Please fill all required fields."),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    //  final controller = Provider.of<SalesController>(context);
    final controller = Provider.of<CustomerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Create Customer",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildFieldLabel("Customer Name", textTheme, colorScheme),

              // Radio buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Individual",
                          style: TextStyle(fontSize: 12)),
                      value: 'Individual',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      dense: true,
                      title: const Text(
                        "Business",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: 'Business',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (_selectedType == 'Business')
                AddSalesFormfield(
                  labelText: "Customer Name",
                  height: 40,

                  controller: _nameController,
                  //validator: _validateRequired,
                ),

              const SizedBox(
                height: 12,
              ),

              if (_selectedType == 'Business')
                AddSalesFormfield(
                  labelText: "Proprietor Name",
                  height: 40,

                  controller: _proprietorController,
                  //validator: _validateRequired,
                ),

              if (_selectedType == 'Individual')
                AddSalesFormfield(
                  labelText: "Name",
                  height: 40,
                  controller: _individualNameController,
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
                labelText: "Phone",
                height: 40,

                controller: _phoneController,
                //validator: _validatePhone,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(
                height: 12,
              ),

              AddSalesFormfield(
                labelText: "Email",
                height: 40,

                controller: _emailController,
                //validator: _validateEmail,
              ),

              const SizedBox(
                height: 12,
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
                            onTap: () => controller.pickDate(context),
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
                                controller.formattedDate.isNotEmpty
                                    ? controller.formattedDate
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
                height: 12,
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ///business logoi
                  if (_selectedType == 'Business')
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
                          "Upload logo",
                          style: TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ],
                    ),

                  const SizedBox(
                    height: 10,
                  ),

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
                                  image: _imageFile2 != null
                                      ? FileImage(File(_imageFile2!.path))
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
                                  _showImageSourceActionSheet2(context);
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
                        "Upload Avater",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: _saveCustomer,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primaryColor,
              //       padding: const EdgeInsets.symmetric(
              //           vertical: 12, horizontal: 20),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //     child: const Text("Save Customer",
              //         style: TextStyle(color: Colors.white)),
              //   ),
              // ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : _saveCustomer, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLoading ? Colors.grey : AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text("Saving...",
                                style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Text("Save Customer",
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
