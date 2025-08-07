import 'dart:io';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/home/provider/profile_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyInfromation extends StatefulWidget {
  const CompanyInfromation({super.key});

  @override
  State<CompanyInfromation> createState() => _CompanyInfromationState();
}

class _CompanyInfromationState extends State<CompanyInfromation> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController couyntryController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController adminNameController = TextEditingController();
  TextEditingController hrIDController = TextEditingController();
  TextEditingController adminEmailController = TextEditingController();
  TextEditingController adminPhoneController = TextEditingController();

  ///image 1
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  ///image 2
  XFile? _imageFile2;
  final ImagePicker _picker2 = ImagePicker();

  Future<void> _pickImage2(ImageSource source) async {
    final XFile? pickedFile2 = await _picker2.pickImage(source: source);

    if (pickedFile2 != null) {
      setState(() {
        _imageFile2 = pickedFile2;
      });
    }
  }

  ///image 3
  XFile? _imageFile3;
  final ImagePicker _picker3 = ImagePicker();

  Future<void> _pickImage3(ImageSource source) async {
    final XFile? pickedFile3 = await _picker3.pickImage(source: source);

    if (pickedFile3 != null) {
      setState(() {
        _imageFile3 = pickedFile3;
      });
    }
  }

  int? userID;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchProfile();
  }

  Future<void> _loadUserIdAndFetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (!mounted) return;
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.fetchCountries();

    if (userId != null) {
      setState(() {
        userID = userId;
      });
      
      // Call fetchProfile after userId is loaded
      
      profileProvider.fetchProfile(userID!);
    } else {
      // Handle null userId
      debugPrint('User ID not found in SharedPreferences');
    }
  }

  void _clearAllFields() {
    companyNameController.clear();
    couyntryController.clear();
    currencyController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    adminNameController.clear();
    hrIDController.clear();
    adminEmailController.clear();
    adminPhoneController.clear();

    setState(() {
      _imageFile = null;
      _imageFile2 = null;
      _imageFile3 = null;
    });
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
        // ignore: prefer_const_constructors
        title: const Text(
          'Company Information',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),

        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: SingleChildScrollView(child:
            Consumer<ProfileProvider>(builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.profile != null) {
            final user = provider.profile!;

            user.email;
            user.phone;
            user.id;

            // ✅ Set email to controller only if not already set
            if (adminEmailController.text.isEmpty) {
              adminEmailController.text =
                  user.email ?? ''; // assuming email might be nullable
            }

            if (adminPhoneController.text.isEmpty) {
              adminPhoneController.text =
                  user.phone ?? ''; // assuming email might be nullable
            }

            if (companyNameController.text.isEmpty) {
              companyNameController.text =
                  user.companyName ?? ''; // assuming email might be nullable
            }

            if (currencyController.text.isEmpty) {
              currencyController.text =
                  user.currency ?? ''; // assuming email might be nullable
            }

            if (couyntryController.text.isEmpty) {
              couyntryController.text =
                  provider.getCountryNameById(user.countryId);
            }

          
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Conmany Information",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),

              ///nick name
              AddSalesFormfield(
                labelText: "Company/Business Name",
                readOnly: true,
                height: 40,
                controller: companyNameController,
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      labelText: "Country",
                      readOnly: true,
                      height: 40,
                      controller: couyntryController,
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      readOnly: true,
                      labelText: "Currency",
                      height: 40,
                      controller: currencyController,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "Email",
                height: 40,
                controller: emailController,
              ),

              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "Phone",
                height: 40,
                controller: phoneController,
              ),
              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "Address",
                height: 40,
                controller: addressController,
              ),

              const SizedBox(
                height: 10,
              ),

              ////logo
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
                    "Company logo",
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "Admin Infromation",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "Admin Name",
                height: 40,
                controller: adminNameController,
              ),

              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "HR ID/NID No.",
                height: 40,
                controller: hrIDController,
              ),

              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "Email",
                readOnly: true,
                height: 40,
                controller: adminEmailController,
              ),

              const SizedBox(
                height: 10,
              ),

              AddSalesFormfield(
                labelText: "Phone",
                readOnly: true,
                height: 40,
                controller: adminPhoneController,
              ),

              const SizedBox(
                height: 10,
              ),

              //company/ customer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ////avatar
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
                                          "assets/image/image_upload_green.png",
                                        ),
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
                        "Admin Image",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ////singture
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
                                  image: _imageFile3 != null
                                      ? FileImage(File(_imageFile3!.path))
                                      : const AssetImage(
                                          "assets/image/image_upload_green.png",
                                        ),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  _showImageSourceActionSheet3(context);
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
                        "Admin Signature",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (userID == null) return;

                    final success = await Provider.of<ProfileProvider>(context,
                            listen: false)
                        .updateProfile(
                      userId: userID!,
                      companyName: companyNameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      currency: currencyController.text,
                      address: addressController.text,
                      name: adminNameController.text,
                      nickName: hrIDController.text,
                      countryId: int.tryParse(couyntryController.text) ?? 0,
                      avatar:
                          _imageFile2 != null ? File(_imageFile2!.path) : null,
                      logo: _imageFile != null ? File(_imageFile!.path) : null,
                      signature:
                          _imageFile3 != null ? File(_imageFile3!.path) : null,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Profile updated successfully')),
                      );
                      _clearAllFields();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeView()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update profile')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Submit",
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(
                height: 30,
              ),
            ],
          );
        })),
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

  void _showImageSourceActionSheet3(BuildContext context) {
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
                  _pickImage3(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage3(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
