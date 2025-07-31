import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill/model/designation_model.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditBillPerson extends StatefulWidget {
  final String billPersonId;
  const EditBillPerson({super.key, required this.billPersonId});

  @override
  State<EditBillPerson> createState() => _EditBillPersonState();
}

class _EditBillPersonState extends State<EditBillPerson> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int? selectedDesignationId;
  String? selectedDesignationName;
  DateTime _selectedDate = DateTime.now();
  String selectedStatus = "1";
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool isLoading = true;

  String? _imageUrl;

  String get formattedDate =>
      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<BillPersonProvider>(context, listen: false);
      await provider.fetchDesignations();
      await fetchBillPersonById();
    });
  }

  
  ///fetch bill person by id.
  Future<void> fetchBillPersonById() async {
    try {
      final uri = Uri.parse(
          "https://commercebook.site/api/v1/bill/person/edit/${widget.billPersonId}");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final bill = data['data'];
          setState(() {
            _nameController.text = bill['name'] ?? '';
            _nickNameController.text = bill['nick_name'] ?? '';
            _phoneController.text = bill['phone'] ?? '';
            _emailController.text = bill['email'] ?? '';
            _addressController.text = bill['address'] ?? '';
            selectedStatus = bill['status'].toString();
            selectedDesignationId = bill['designation'];

            final provider =
                Provider.of<BillPersonProvider>(context, listen: false);
            final selected = provider.designations.firstWhere(
              (d) => d.id == selectedDesignationId,
              orElse: () => DesignationModel(id: 0, name: '', status: 1),
            );
            selectedDesignationName = selected.name;

            // ✅ Load image URL from API
            _imageUrl = bill['avatar'] != null
                ? 'https://commercebook.site/${bill['avatar']}'
                : null;

            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching bill person: \$e");
    }
  }

  ///pick image
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  ///date pick
  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  
  ///image shource action sheet
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
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
  }

  
  ///submit.
  Future<void> _submit() async {
    final provider = Provider.of<BillPersonProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getInt('user_id')?.toString();

    if (_nameController.text.isEmpty ||
        _nickNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Add required field."), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await provider.updateBillPerson(
      id: widget.billPersonId,
      userId: userId!,
      name: _nameController.text,
      nickName: _nickNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      designation: selectedDesignationId.toString(),
      address: _addressController.text,
      date: formattedDate,
      status: selectedStatus,
      avatarFile: _imageFile != null ? File(_imageFile!.path) : null,
    );

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Successfully, Update Bill Person"), backgroundColor: Colors.green),
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage), backgroundColor: Colors.red),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Bill Person',
            style: TextStyle(color: Colors.yellow, fontSize: 16)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AddSalesFormfield(
                            labelText: "Name",
                            height: 40,
                            controller: _nameController),
                        const SizedBox(
                          height: 12,
                        ),
                        AddSalesFormfield(
                            labelText: "Nick Name",
                            height: 40,
                            controller: _nickNameController),
                        const SizedBox(
                          height: 12,
                        ),
                        AddSalesFormfield(
                            labelText: "Phone",
                            height: 40,
                            controller: _phoneController,
                            keyboardType: TextInputType.number),
                        const SizedBox(
                          height: 12,
                        ),
                        AddSalesFormfield(
                            labelText: "Email",
                            height: 40,
                            controller: _emailController),
                        const SizedBox(
                          height: 12,
                        ),
                        AddSalesFormfield(
                            labelText: "Address",
                            height: 40,
                            controller: _addressController),
                        const SizedBox(
                          height: 12,
                        ),
                        Consumer<BillPersonProvider>(
                          builder: (_, provider, __) => CustomDropdownTwo(
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
                                final d = provider.designations
                                    .firstWhere((d) => d.name == value);
                                selectedDesignationId = d.id;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await DateTimeHelper.pickDate(
                                context, _selectedDate);
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate =
                                    picked; // ✅ setState ensures UI updates
                              });
                            }
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color
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
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                suffixIcon:
                                    Icon(Icons.calendar_today, size: 16),
                                hintText: "Bill Date",
                                border: InputBorder.none,
                              ),
                              child: Text(
                                formattedDate, // ✅ this always returns valid date
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // CustomDropdownTwo(
                        //   items: const ["Active", "Inactive"],
                        //   labelText: 'Status',
                        //   width: double.infinity,
                        //   height: 40,
                        //   value: selectedStatus == "1" ? "Active" : "Inactive",
                        //   onChanged: (value) {
                        //     setState(() =>
                        //         selectedStatus = value == "Active" ? "1" : "0");
                        //   },
                        // ),
                        const SizedBox(height: 12),
                        ///image fetch
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
                                            as ImageProvider
                                        : (_imageUrl != null
                                            ? NetworkImage(_imageUrl!)
                                            : const AssetImage(
                                                "assets/image/image_upload_blue.png")),
                                    fit: BoxFit.cover,
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
                        const SizedBox(height: 4),
                        const Text("Image", style: TextStyle(fontSize: 13)),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Update Bill Person",
                        style: TextStyle(color: Colors.white),
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
