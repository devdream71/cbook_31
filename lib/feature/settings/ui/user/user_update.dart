import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/payment_out/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:cbook_dt/feature/settings/ui/user/model/role_model.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class UserUpdate extends StatefulWidget {
  final int userId;
  const UserUpdate({super.key, required this.userId});

  @override
  State<UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<UserUpdate> {
  //String? selectedRoleName;
  int selectedRoleId = 0;

  String? selectedDesignationName;
  int? selectedDesignationId;

  String? selectedBillPerson;
  int? selectedBillPersonId;

  String selectedRoleName = '';

  String? selectedDefaultBillPerson;
  int? selectedDefaultBillPersonId;

  String selectedStatus = "1";

  String? avatarUrl;

  XFile? _imageFile;
  XFile? _imageFile2;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _pickSignature(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile2 = pickedFile);
    }
  }

  @override
  void initState() {
    super.initState();

    final userProvider =
        Provider.of<SettingUserProvider>(context, listen: false);

    Future.microtask(() async {
      await userProvider.fetchRoles();
      await userProvider.fetchUserById(widget.userId);
      _populateFields(userProvider);
    });

    Future.microtask(() =>
        Provider.of<BillPersonProvider>(context, listen: false)
            .fetchDesignations());

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());
  }

  void _populateFields(SettingUserProvider provider) {
    final user = provider.editUser;
    if (user != null) {
      provider.nameController.text = user.name;
      provider.nickController.text = user.nickName;
      provider.phoneController.text = user.phone;
      //provider.emailController.text = user.userType; // Assuming this is email
      provider.addressController.text = user.address;

      // ✅ Avatar URL
      if (user.avatar != null && user.avatar!.isNotEmpty) {
        avatarUrl = "https://commercebook.site/${user.avatar}";
      }

      setState(() {
        selectedRoleId = user.roleId;
        selectedRoleName = provider.roles
            .firstWhere((role) => role.id == user.roleId,
                orElse: () => provider.roles.first)
            .name;

        selectedDesignationId = user.designationId;
        selectedDesignationName =
            Provider.of<BillPersonProvider>(context, listen: false)
                .designations
                .firstWhere((d) => d.id == user.designationId,
                    orElse: () =>
                        Provider.of<BillPersonProvider>(context, listen: false)
                            .designations
                            .first)
                .name;

        selectedBillPersonId = user.billPersonId;
        selectedBillPerson = Provider.of<PaymentVoucherProvider>(context,
                listen: false)
            .billPersons
            .firstWhere((bp) => bp.id == user.billPersonId,
                orElse: () =>
                    Provider.of<PaymentVoucherProvider>(context, listen: false)
                        .billPersons
                        .first)
            .name;

        selectedDefaultBillPersonId = user.defaultBillPersonId;
        selectedDefaultBillPerson = Provider.of<PaymentVoucherProvider>(context,
                listen: false)
            .billPersons
            .firstWhere((bp) => bp.id == user.defaultBillPersonId,
                orElse: () =>
                    Provider.of<PaymentVoucherProvider>(context, listen: false)
                        .billPersons
                        .first)
            .name;

        selectedStatus = user.status.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<SettingUserProvider>(context);

    final nameController = provider.nameController;
    final nickController = provider.nickController;
    final phoneController = provider.phoneController;
    final emailController = provider.emailController;
    final addressController = provider.addressController;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit User',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        /// name, nick name
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                height: 40,
                                labelText: "Name",
                                controller: nameController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AddSalesFormfield(
                                height: 40,
                                labelText: "Nick Name",
                                controller: nickController,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// phone, email
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                height: 40,
                                labelText: "Phone",
                                controller: phoneController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AddSalesFormfield(
                                height: 40,
                                labelText: "Email",
                                controller: emailController,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        AddSalesFormfield(
                          height: 40,
                          labelText: "Address",
                          controller: addressController,
                        ),

                        const SizedBox(height: 10),

                        /// designation & user type
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<BillPersonProvider>(
                                builder: (context, billProvider, child) {
                                  return CustomDropdownTwo(
                                    items: billProvider.designations
                                        .map((e) => e.name)
                                        .toList(),
                                    width: double.infinity,
                                    height: 40,
                                    labelText: 'Designation',
                                    selectedItem: selectedDesignationName,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDesignationName = value;
                                        selectedDesignationId = billProvider
                                            .designations
                                            .firstWhere((d) => d.name == value)
                                            .id;
                                      });
                                      debugPrint(
                                          'selectedDesignationId: ${selectedDesignationId}');
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Consumer<SettingUserProvider>(
                                builder: (context, roleProvider, child) {
                                  return CustomDropdownTwo(
                                    items: roleProvider.roles
                                        .map((e) => e.name)
                                        .toList(),
                                    width: double.infinity,
                                    height: 40,
                                    labelText: 'User Type',
                                    selectedItem: selectedRoleName,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRoleName = value;

                                        final selected =
                                            provider.roles.firstWhere(
                                          (r) => r.name == value,
                                          orElse: () => RoleModel(
                                              id: 0, name: '', status: 1),
                                        );

                                        selectedRoleId = selected.id;

                                        // 🔥 Print user_name_user_id format
                                        final rolePrint =
                                            "${selected.name.toLowerCase()}_${selected.id}";
                                        debugPrint(
                                            "👤 Selected User Type: $rolePrint");
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Bill Person & Default Bill Person
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<PaymentVoucherProvider>(
                                builder: (context, provider, child) {
                                  return provider.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : CustomDropdownTwo(
                                          items: provider.billPersonNames,
                                          width: double.infinity,
                                          height: 40,
                                          labelText: 'Bill Person',
                                          selectedItem: selectedBillPerson,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedBillPerson = value;
                                              selectedBillPersonId = provider
                                                  .billPersons
                                                  .firstWhere(
                                                      (p) => p.name == value)
                                                  .id;

                                              debugPrint(
                                                  'selectedBillPersonId $selectedBillPersonId');
                                            });
                                          },
                                        );
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Consumer<PaymentVoucherProvider>(
                                builder: (context, provider, child) {
                                  return provider.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : CustomDropdownTwo(
                                          items: provider.billPersonNames,
                                          width: double.infinity,
                                          height: 40,
                                          labelText: 'Default Bill Person',
                                          selectedItem:
                                              selectedDefaultBillPerson,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedDefaultBillPerson = value;
                                              selectedDefaultBillPersonId =
                                                  provider
                                                      .billPersons
                                                      .firstWhere((p) =>
                                                          p.name == value)
                                                      .id;

                                              debugPrint(
                                                  'selectedBillPersonId $selectedDefaultBillPersonId');
                                            });
                                          },
                                        );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        ////status , date
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
                                      color: Colors
                                          .transparent, // Background color
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 0.5), // Border
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey
                                              .withOpacity(0.1), // Light shadow
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: const Offset(
                                              0, 1), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () => provider.pickDate(context),
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          suffixIconConstraints:
                                              const BoxConstraints(
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
                                          provider.formattedDate.isNotEmpty
                                              ? provider.formattedDate
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
                                controller: provider.passwordController,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: AddSalesFormfield(
                                height: 40,
                                labelText: "Confirm Password",
                                controller: provider.confromController,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Avatar & Signature
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _pickImage(ImageSource.gallery),
                                  child: Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: _imageFile != null
                                            ? FileImage(File(_imageFile!.path))
                                            : avatarUrl != null
                                                ? NetworkImage(avatarUrl!)
                                                : const AssetImage(
                                                        "assets/image/image_upload_blue.png")
                                                    as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Avatar",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _pickSignature(ImageSource.gallery),
                                  child: Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: _imageFile2 != null
                                            ? FileImage(File(_imageFile2!.path))
                                            : const AssetImage(
                                                    "assets/image/image_upload_green.png")
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const Text("Signature",
                                    style: TextStyle(color: Colors.black)),
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        

                        final provider = Provider.of<SettingUserProvider>(
                            context,
                            listen: false);

                        final result = await provider.updateUser(
                          id: widget.userId,
                          userType:
                              '${selectedRoleName.toLowerCase()}_$selectedRoleId',
                          //roleId: selectedRoleId,
                          designation: selectedDesignationId ?? 0,
                          password: provider.passwordController.text.trim(),
                          billPersonIds: selectedBillPersonId?.toString() ?? '',
                          defaultBillPerson: selectedDefaultBillPersonId ?? 0,
                          status: selectedStatus,
                          createdDate: provider.formattedDate.isNotEmpty
                              ? provider.formattedDate
                              : '2025-07-14',
                          avatar: _imageFile,
                          signature: _imageFile2,
                        );

                        final success = result['success'] as bool;
                        final message =
                            result['message'] ?? 'Something went wrong';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(message.toString())),
                        );

                        provider.fetchUsers();

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeView()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("Update User",
                          style: TextStyle(color: Colors.white)),
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
