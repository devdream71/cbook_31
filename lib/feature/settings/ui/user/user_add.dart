import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill/model/designation_model.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:cbook_dt/feature/settings/ui/user/model/role_model.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserAdd extends StatefulWidget {
  const UserAdd({
    super.key,
  });

  @override
  State<UserAdd> createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  TextEditingController nameController = TextEditingController();

  String selectedStatus = "1";

  String selectedRoleName = '';
  int selectedRoleId = 0;

  int? selectedDesignationId;
  String? selectedDesignationName;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  // For Default Bill Person
  String? selectedDefaultBillPerson;
  int? selectedDefaultBillPersonId;
  BillPersonModel? selectedDefaultBillPersonData;

  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;
  XFile? _imageFile2;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  final ImagePicker _picker2 = ImagePicker();

  Future<void> _pickImage2(ImageSource source) async {
    final XFile? pickedFile2 = await _picker2.pickImage(source: source);

    if (pickedFile2 != null) {
      setState(() {
        _imageFile2 = pickedFile2;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BillPersonProvider>(context, listen: false)
          .fetchDesignations();
    });

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    final provider = Provider.of<SettingUserProvider>(context, listen: false);
    provider.fetchRoles();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Provider.of<SettingUserProvider>(context);
    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Add User",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
          child: Column(
            children: [
              ///name , nick name
              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      height: 40,
                      labelText: "Name",
                      controller: controller.nameController,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      height: 40,
                      labelText: "Nick Name",
                      controller: controller.nickController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ///mobile , email
              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      height: 40,
                      labelText: "Phone",
                      controller: controller.phoneController,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      height: 40,
                      labelText: "Email",
                      controller: controller.emailController,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              ///addresss
              AddSalesFormfield(
                height: 40,
                labelText: "Address",
                controller: controller.addressController,
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  ///title, designation
                  Expanded(
                    child:

                        ///designation
                        Consumer<BillPersonProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: provider.designations
                                .map((e) => e.name)
                                .toList(),
                            width: double.infinity,
                            height: 40,
                            labelText: 'Designation',
                            selectedItem: selectedDesignationName,
                            onChanged: (value) {
                              setState(() {
                                selectedDesignationName = value;
                                final selected =
                                    provider.designations.firstWhere(
                                  (d) => d.name == value,
                                  orElse: () => DesignationModel(
                                      id: 0, name: '', status: 1),
                                );
                                selectedDesignationId = selected.id;
                                debugPrint(
                                    'Selected Designation ID: $selectedDesignationId');
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),

                  ///User Type
                  Expanded(
                    child: Consumer<SettingUserProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: provider.roles.map((e) => e.name).toList(),
                            width: double.infinity,
                            height: 40,
                            labelText: 'User Type',
                            selectedItem:
                                selectedRoleName, // You define this in your State
                            onChanged: (value) {
                              setState(() {
                                selectedRoleName = value;

                                final selected = provider.roles.firstWhere(
                                  (r) => r.name == value,
                                  orElse: () =>
                                      RoleModel(id: 0, name: '', status: 1),
                                );

                                selectedRoleId = selected.id;

                                // 🔥 Print user_name_user_id format
                                final rolePrint =
                                    "${selected.name.toLowerCase()}_${selected.id}";
                                debugPrint("👤 Selected User Type: $rolePrint");
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              /// Bill Person & Default Bill Person Dropdowns
              Row(
                children: [
                  // 🔵 Bill Person Dropdown
                  Expanded(
                    child: Consumer<PaymentVoucherProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 40,
                          width: 130,
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomDropdownTwo(
                                  hint: '',
                                  items: provider.billPersonNames,
                                  width: double.infinity,
                                  height: 30,
                                  labelText: 'Bill Person',
                                  selectedItem: selectedBillPerson,
                                  onChanged: (value) {
                                    debugPrint(
                                        '🔵 Bill Person Selected: $value');
                                    setState(() {
                                      selectedBillPerson = value;
                                      selectedBillPersonData =
                                          provider.billPersons.firstWhere(
                                        (person) => person.name == value,
                                      );
                                      selectedBillPersonId =
                                          selectedBillPersonData!.id;
                                    });

                                    debugPrint('🔵 Bill Person Details:');
                                    debugPrint(
                                        '- ID: ${selectedBillPersonData!.id}');
                                    debugPrint(
                                        '- Name: ${selectedBillPersonData!.name}');
                                    debugPrint(
                                        '- Phone: ${selectedBillPersonData!.phone}');
                                  },
                                ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 5),

                  // 🟣 Default Bill Person Dropdown
                  Expanded(
                    child: Consumer<PaymentVoucherProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 40,
                          width: 130,
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomDropdownTwo(
                                  hint: '',
                                  items: provider.billPersonNames,
                                  width: double.infinity,
                                  height: 30,
                                  labelText: 'Default Bill Person',
                                  selectedItem: selectedDefaultBillPerson,
                                  onChanged: (value) {
                                    debugPrint(
                                        '🟣 Default Bill Person Selected: $value');
                                    setState(() {
                                      selectedDefaultBillPerson = value;
                                      selectedDefaultBillPersonData =
                                          provider.billPersons.firstWhere(
                                        (person) => person.name == value,
                                      );
                                      selectedDefaultBillPersonId =
                                          selectedDefaultBillPersonData!.id;
                                    });

                                    debugPrint(
                                        '🟣 Default Bill Person Details:');
                                    debugPrint(
                                        '- ID: ${selectedDefaultBillPersonData!.id}');
                                    debugPrint(
                                        '- Name: ${selectedDefaultBillPersonData!.name}');
                                    debugPrint(
                                        '- Phone: ${selectedDefaultBillPersonData!.phone}');
                                  },
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              ////status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: const [
                              "Active",
                              "Inactive"
                            ], // Display labels
                            //hint: '', // Select Status
                            width: double.infinity,
                            labelText: 'Status',
                            height: 40,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = (value == "Active")
                                    ? "1"
                                    : "0"; // ✅ Save 1 or 0
                              });
                              debugPrint(selectedStatus);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
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
                                //hintText: "Bill Date",
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
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      height: 40,
                      labelText: "Password",
                      controller: controller.passwordController,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      height: 40,
                      labelText: "Confirm Password",
                      controller: controller.confromController,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///avater
                  Column(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const Text(
                              "Avater",
                              style: TextStyle(color: Colors.black),
                            ),
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
                        "Avater",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  //signature.
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
                        "Singture",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "***Nick Name must be 8 carecteres (AA or 123)",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = controller.nameController.text.trim();
                    final nickName = controller.nickController.text.trim();
                    final phone = controller.phoneController.text.trim();
                    final email = controller.emailController.text.trim();
                    final address = controller.addressController.text.trim();
                    final password = controller.passwordController.text.trim();
                    final confirmPassword =
                        controller.confromController.text.trim();

                    // Check for empty required fields
                    if (name.isEmpty ||
                        nickName.isEmpty ||
                        phone.isEmpty ||
                        email.isEmpty ||
                        address.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty ||
                        selectedDesignationId == null ||
                        selectedRoleId == 0 ||
                        selectedBillPersonId == null ||
                        selectedDefaultBillPersonId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Password match check
                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Password and Confirm Password do not match!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final provider = Provider.of<SettingUserProvider>(context,
                        listen: false);
                    final result = await provider.createUser(
                      userType:
                          "${selectedRoleName.toLowerCase()}_${selectedRoleId}",
                      name: controller.nameController.text.trim(),
                      nickName: controller.nickController.text.trim(),
                      email: controller.emailController.text.trim(),
                      phone: controller.phoneController.text.trim(),
                      password: controller.passwordController.text.trim(),
                      designation: selectedDesignationId.toString(),
                      billPersonId: selectedBillPersonId.toString(),
                      defaultBillPersonId:
                          selectedDefaultBillPersonId.toString(),
                      address: controller.addressController.text.trim(),
                      createdDate: controller.formattedDate,
                      status: selectedStatus,
                      avatarPath: _imageFile!.path,
                      signaturePath: _imageFile2!.path,
                    );

                    if (result != null && result.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(result.message),
                            backgroundColor: Colors.green),
                      );

                      provider.fetchUsers();

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeView()));

                      // if (mounted) {
                      //   Navigator.pop(context);
                      // }

                      // Future.delayed(const Duration(milliseconds: 300), () {
                      //   if (mounted) {
                      //     Navigator.pop(context);
                      //   }
                      // });

                      // Navigator.pop(context); // or refresh list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Failed to create user"),
                            backgroundColor: Colors.red),
                      );
                    }

                    // ✅ All checks passed
                    debugPrint("✅ All fields validated. Ready to save.");

                    // Call your user save API or function here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text("Save User",
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              ///
            ],
          ),
        ));
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
