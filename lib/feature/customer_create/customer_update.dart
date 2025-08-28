import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/price_option_selector_customer.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create_model.dart';
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
  late TextEditingController opeinigBalance;
  late TextEditingController idController;

  final TextEditingController _statusController = TextEditingController();

  // Image picker functionality for both avatar and logo
  final ImagePicker _picker = ImagePicker();
  XFile? _avatarImageFile;
  XFile? _logoImageFile;
  String? _existingAvatar;
  String? _existingLogo;

  // @override
  // void initState() {
  //   super.initState();

  //   // Debugging: Ensure customer data is passed correctly
  //   debugPrint("Customer Data:");
  //   debugPrint("ID: ${widget.customer.id}");
  //   debugPrint("Name: ${widget.customer.name}");
  //   debugPrint("Avatar: ${widget.customer.avatar}");
  //   debugPrint("Logo: ${widget.customer.logo}");

  //   // Initialize controllers with the passed customer data
  //   nameController = TextEditingController(text: widget.customer.name);
  //   proprietorController =
  //       TextEditingController(text: widget.customer.proprietorName ?? '');
  //   emailController = TextEditingController(text: widget.customer.email ?? '');
  //   opeinigBalance =
  //       TextEditingController(text: widget.customer.openingBalance.toString());

  //   phoneController = TextEditingController(text: widget.customer.phone ?? '');
  //   addressController =
  //       TextEditingController(text: widget.customer.address ?? '');
  //   idController = TextEditingController(text: widget.customer.id.toString());

  //   // Set existing images
  //   _existingAvatar = widget.customer.avatar;
  //   _existingLogo = widget.customer.logo;

  //   // Check if customer has a level
  //   if (widget.customer.level != null && widget.customer.level! > 0) {
  //     _selectedPrice = widget.customer.levelType ?? "";
  //     _isChecked = true;
  //   } else {
  //     _selectedPrice = "";
  //     _isChecked = false;
  //   }
  // }

  @override
  void initState() {
    super.initState();

    // Debugging: Ensure customer data is passed correctly
    debugPrint("Customer Data:");
    debugPrint("ID: ${widget.customer.id}");
    debugPrint("Name: ${widget.customer.name}");
    debugPrint("Proprietor Name: ${widget.customer.proprietorName}");
    debugPrint("Avatar: ${widget.customer.avatar}");
    debugPrint("Logo: ${widget.customer.logo}");
    debugPrint("Opening Balance: ${widget.customer.openingBalance}");

    // Initialize controllers with the passed customer data
    nameController = TextEditingController(text: widget.customer.name);
    proprietorController =
        TextEditingController(text: widget.customer.proprietorName ?? '');
    emailController = TextEditingController(text: widget.customer.email ?? '');
    phoneController = TextEditingController(text: widget.customer.phone ?? '');
    addressController =
        TextEditingController(text: widget.customer.address ?? '');
    idController = TextEditingController(text: widget.customer.id.toString());

    // Fix opening balance to show without decimal if it's a whole number
    double balance = widget.customer.openingBalance;
    String balanceText;
    if (balance == balance.toInt()) {
      // If it's a whole number, show without decimal
      balanceText = balance.toInt().toString();
    } else {
      // If it has decimals, show with decimals
      balanceText = balance.toString();
    }
    opeinigBalance = TextEditingController(text: balanceText);

    // Set existing images
    _existingAvatar = widget.customer.avatar;
    _existingLogo = widget.customer.logo;

    // Check if customer has a level
    if (widget.customer.level != null && widget.customer.level! > 0) {
      _selectedPrice = widget.customer.levelType ?? "";
      _isChecked = true;
    } else {
      _selectedPrice = "";
      _isChecked = false;
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

  // Image picker methods for avatar
  void _pickAvatarImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _avatarImageFile = pickedFile;
      });
    }
  }

  // Image picker methods for logo
  void _pickLogoImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _logoImageFile = pickedFile;
      });
    }
  }

  void _showAvatarImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Avatar Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatarImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatarImage(ImageSource.camera);
                },
              ),
              // if (_avatarImageFile != null ||
              //     (_existingAvatar != null && _existingAvatar!.isNotEmpty))
              //   ListTile(
              //     leading: const Icon(Icons.delete, color: Colors.red),
              //     title: const Text('Remove Avatar'),
              //     onTap: () {
              //       Navigator.of(context).pop();
              //       setState(() {
              //         _avatarImageFile = null;
              //         _existingAvatar = null;
              //       });
              //     },
              //   ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Logo Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickLogoImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickLogoImage(ImageSource.camera);
                },
              ),
              // if (_logoImageFile != null ||
              //     (_existingLogo != null && _existingLogo!.isNotEmpty))
              //   ListTile(
              //     leading: const Icon(Icons.delete, color: Colors.red),
              //     title: const Text('Remove Logo'),
              //     onTap: () {
              //       Navigator.of(context).pop();
              //       setState(() {
              //         _logoImageFile = null;
              //         _existingLogo = null;
              //       });
              //     },
              //   ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    bool hasAvatar = _avatarImageFile != null ||
        (_existingAvatar != null && _existingAvatar!.isNotEmpty);
    bool hasLogo = _logoImageFile != null ||
        (_existingLogo != null && _existingLogo!.isNotEmpty);

    if (hasAvatar && hasLogo) {
      // Show both images side by side
      return Column(
        children: [
          // const Text(
          //   'Profile Images',
          //   style: TextStyle(
          //       fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          // ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Avatar section
              Column(
                children: [
                  const Text('Logo',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(height: 4),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.green[100],
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _avatarImageFile != null
                              ? FileImage(File(_avatarImageFile!.path))
                              : NetworkImage(
                                  "https://commercebook.site/$_existingLogo"),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () =>
                              _showAvatarImageSourceActionSheet(context),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.camera_alt, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Logo section
              Column(
                children: [
                  const Text('Avater',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(height: 4),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.green[100]!, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: _logoImageFile != null
                              ? Image.file(
                                  File(_logoImageFile!.path),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  "https://commercebook.site/$_existingAvatar",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.business, size: 40);
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _showLogoImageSourceActionSheet(context),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.camera_alt, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else if (hasAvatar) {
      // Show only avatar
      return Column(
        children: [
          const Text('logo',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.green[100],
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _avatarImageFile != null
                      ? FileImage(File(_avatarImageFile!.path))
                      : NetworkImage(
                          "https://commercebook.site/$_existingLogo"),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _showAvatarImageSourceActionSheet(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.camera_alt, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // TextButton.icon(
          //   onPressed: () => _showLogoImageSourceActionSheet(context),
          //   icon: const Icon(Icons.add_a_photo),
          //   label: const Text('Add Logo'),
          // ),
        ],
      );
    } else if (hasLogo) {
      // Show only logo
      return Column(
        children: [
          const Text('avater',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green[100]!, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: _logoImageFile != null
                      ? Image.file(File(_logoImageFile!.path),
                          fit: BoxFit.cover)
                      : Image.network(
                          "https://commercebook.site/$_existingAvatar",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.business, size: 60);
                          },
                        ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _showLogoImageSourceActionSheet(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.camera_alt, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showAvatarImageSourceActionSheet(context),
            icon: const Icon(Icons.add_a_photo),
            label: const Text(
              'Add Avatar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    } else {
      // Show add both options
      return Column(
        children: [
          const Text('Add Images',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 12),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => _showAvatarImageSourceActionSheet(context),
                icon: const Icon(Icons.person_add),
                label: const Text(
                  'Add Avatar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showLogoImageSourceActionSheet(context),
                icon: const Icon(Icons.business),
                label: const Text('Add Logo',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      );
    }
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
                    // Image section
                    Center(child: _buildImageSection()),
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
                          if (!value) _selectedPrice = "";
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

                    const SizedBox(height: 12),

                    AddSalesFormfield(
                      height: 40,
                      labelText: 'Opeinig Balance',
                      controller: opeinigBalance,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Update button
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {

            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor,
            //       padding:
            //           const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     child: const Text(
            //       "Update Party",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),

            //             // ✅ Update button
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

                    String level =
                        _isChecked ? "1" : "0"; // If checked, level is "1"
                    String levelType = _isChecked
                        ? _selectedPrice
                        : ""; // Assign only if level is 1

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
                      // imageFile:
                      //     _imageFile != null ? File(_imageFile!.path) : null,
                    );

                    await customerProvider.fetchCustomsr();

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

                        await customerProvider.fetchCustomsr();

                        Navigator.of(context).pop(true); // Return success
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Error: ${customerProvider.errorMessage}"),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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



// import 'dart:io';
// import 'package:cbook_dt/app_const/app_colors.dart';
// import 'package:cbook_dt/common/price_option_selector_customer.dart';
// import 'package:cbook_dt/feature/customer_create/model/customer_create_model.dart';
// import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
// import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';

// class CustomerUpdate extends StatefulWidget {
//   final CustomerData customer;

//   const CustomerUpdate({
//     super.key,
//     required this.customer,
//   });

//   @override
//   CustomerUpdateState createState() => CustomerUpdateState();
// }

// class CustomerUpdateState extends State<CustomerUpdate> {
//   late TextEditingController nameController;
//   late TextEditingController proprietorController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//   late TextEditingController addressController;
//   late TextEditingController idController;

//   final TextEditingController _statusController = TextEditingController();

//   // ✅ Image picker functionality
//   final ImagePicker _picker = ImagePicker();
//   XFile? _imageFile;
//   String? _existingImage;

//   @override
//   void initState() {
//     super.initState();

//     // Debugging: Ensure customer data is passed correctly
//     debugPrint("Customer Data:");
//     debugPrint("ID: ${widget.customer.id}");
//     debugPrint("Name: ${widget.customer.name}");
//     debugPrint("Proprietor Name: ${widget.customer.proprietorName}");
//     debugPrint("Email: ${widget.customer.email}");
//     debugPrint("Phone: ${widget.customer.phone}");
//     debugPrint("Address: ${widget.customer.address}");
//     //debugPrint("Avatar: ${widget.customer.avatar}");
//     debugPrint("Status: ${widget.customer.status}");

//     // Initialize controllers with the passed customer data
//     nameController = TextEditingController(text: widget.customer.name);
//     proprietorController =
//         TextEditingController(text: widget.customer.proprietorName ?? '');
//     emailController = TextEditingController(text: widget.customer.email ?? '');
//     phoneController = TextEditingController(text: widget.customer.phone ?? '');
//     addressController =
//         TextEditingController(text: widget.customer.address ?? '');
//     idController = TextEditingController(text: widget.customer.id.toString());

//     // ✅ Set existing image
//     _existingImage = widget.customer.avatar;

//     // Check if customer has a level (fixing the error)
//     if (widget.customer.level != null && widget.customer.level! > 0) {
//       _selectedPrice =
//           widget.customer.levelType ?? ""; // Assign existing levelType
//       _isChecked = true; // Check the checkbox if level exists
//     } else {
//       _selectedPrice = ""; // Reset dropdown if no level
//       _isChecked = false; // Uncheck checkbox
//     }
//   }

//   String _selectedPrice = "";
//   bool _isChecked = false;
//   String selectedStatus = "1";

//   String _selectedPriceD = '';
//   bool _ischeck = false;
//   String selectedStarus = '1' ;

//   @override
//   void dispose() {
//     nameController.dispose();
//     proprietorController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     idController.dispose();
//     super.dispose();
//   }

//   // ✅ Image picker methods
//   void _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = pickedFile;
//       });
//     }
//   }

//   void _showImageSourceActionSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               if (_imageFile != null ||
//                   (_existingImage != null && _existingImage!.isNotEmpty))
//                 ListTile(
//                   leading: const Icon(Icons.delete, color: Colors.red),
//                   title: const Text('Remove Image'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     setState(() {
//                       _imageFile = null;
//                       _existingImage = null;
//                     });
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       backgroundColor: AppColors.sfWhite,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         automaticallyImplyLeading: true,
//         backgroundColor: colorScheme.primary,
//         centerTitle: true,
//         title: const Text("Update Party",
//             style: TextStyle(color: Colors.yellow, fontSize: 14)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ✅ Image picker section
//                     Center(
//                       child: Stack(
//                         alignment: Alignment.bottomRight,
//                         children: [
//                           CircleAvatar(
//                             radius: 65,
//                             backgroundColor: Colors.green[100],
//                             child: CircleAvatar(
//                               radius: 60,
//                               backgroundImage: _imageFile != null
//                                   ? FileImage(File(_imageFile!.path))
//                                   : (_existingImage != null &&
//                                               _existingImage!.isNotEmpty
//                                           ? NetworkImage(
//                                               "https://commercebook.site/$_existingImage")
//                                           : const AssetImage(
//                                               'assets/image/image_color.png'))
//                                       as ImageProvider,
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 4,
//                             right: 4,
//                             child: GestureDetector(
//                               onTap: () => _showImageSourceActionSheet(context),
//                               child: Container(
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white,
//                                 ),
//                                 padding: const EdgeInsets.all(6),
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   size: 20,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     AddSalesFormfield(
//                       height: 40,
//                       labelText: "Party Name",
//                       controller: nameController,
//                     ),

//                     const SizedBox(height: 12),

//                     AddSalesFormfield(
//                       height: 40,
//                       labelText: 'Proprietor Name',
//                       controller: proprietorController,
//                     ),

//                     const SizedBox(height: 12),

//                     // Conditionally render the PriceOptionSelectorCustomer widget
//                     PriceOptionSelectorCustomer(
//                       title: "Price Level",
//                       selectedPrice: _selectedPrice,
//                       onPriceChanged: (value) {
//                         setState(() {
//                           _selectedPrice =
//                               value?.replaceAll(" ", "_").toLowerCase() ?? "";
//                         });
//                       },
//                       isChecked: _isChecked,
//                       onCheckedChanged: (value) {
//                         setState(() {
//                           _isChecked = value;
//                           if (!value)
//                             _selectedPrice = ""; // Reset dropdown if unchecked
//                         });
//                       },
//                     ),

//                     AddSalesFormfield(
//                       height: 40,
//                       labelText: "Email",
//                       controller: emailController,
//                     ),

//                     const SizedBox(height: 12),

//                     AddSalesFormfield(
//                       height: 40,
//                       labelText: "Phone",
//                       controller: phoneController,
//                       keyboardType: TextInputType.number,
//                     ),

//                     const SizedBox(height: 12),

//                     AddSalesFormfield(
//                       height: 40,
//                       labelText: 'Address',
//                       controller: addressController,
//                     ),

//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),

//             // ✅ Update button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   // Show loading dialog
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (context) => const AlertDialog(
//                       content: Row(
//                         children: [
//                           CircularProgressIndicator(),
//                           SizedBox(width: 16),
//                           Text('Updating customer...'),
//                         ],
//                       ),
//                     ),
//                   );

//                   try {
//                     final customerProvider =
//                         Provider.of<CustomerProvider>(context, listen: false);

//                     int customerId = widget.customer.id;
//                     if (customerId == 0) {
//                       Navigator.of(context).pop(); // Close loading dialog
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Invalid Party ID")),
//                       );
//                       return;
//                     }

//                     String level =
//                         _isChecked ? "1" : "0"; // If checked, level is "1"
//                     String levelType = _isChecked
//                         ? _selectedPrice
//                         : ""; // Assign only if level is 1

//                     // ✅ Call the update method with image
//                     await customerProvider.updateCustomerWithImage(
//                       context: context,
//                       id: customerId.toString(),
//                       name: nameController.text,
//                       proprietorName: proprietorController.text,
//                       email: emailController.text,
//                       phone: phoneController.text,
//                       address: addressController.text,
//                       status: selectedStatus,
//                       level: level,
//                       levelType: levelType,
//                       imageFile:
//                           _imageFile != null ? File(_imageFile!.path) : null,
//                     );

//                     // Close loading dialog
//                     if (mounted) Navigator.of(context).pop();

//                     if (mounted) {
//                       if (customerProvider.errorMessage.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: const Text(
//                               "Party updated successfully",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             backgroundColor: AppColors.primaryColor,
//                           ),
//                         );
//                         Navigator.of(context).pop(true); // Return success
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content:
//                                 Text("Error: ${customerProvider.errorMessage}"),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     }
//                   } catch (e) {
//                     // Close loading dialog
//                     if (mounted) Navigator.of(context).pop();

//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("Error: $e"),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   "Update Party",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
// }
