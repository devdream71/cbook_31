import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill/bill_person_list.dart';
import 'package:cbook_dt/feature/settings/ui/bill/model/designation_model.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillCreate extends StatefulWidget {
  const BillCreate({super.key});

  @override
  State<BillCreate> createState() => _BillCreateState();
}

class _BillCreateState extends State<BillCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int? selectedDesignationId;
  String? selectedDesignationName;

  DateTime _selectedDate = DateTime.now();

  String get formattedDate =>
      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  String selectedStatus = "1";

  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  ///pick date.
  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    ///fetch designation.
    Future.microtask(() {
      Provider.of<BillPersonProvider>(context, listen: false)
          .fetchDesignations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            'Bill Person Create',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///name
                    AddSalesFormfield(
                      labelText: "Name",
                      height: 40,
                      controller: _nameController,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ///nick name
                    AddSalesFormfield(
                      labelText: "Nick Name",
                      height: 40,
                      controller: _nickNameController,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ///phone
                    AddSalesFormfield(
                      labelText: "Phone",
                      height: 40,
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ///email
                    AddSalesFormfield(
                      labelText: "Email",
                      height: 40,
                      controller: _emailController,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

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

                    const SizedBox(
                      height: 12,
                    ),

                    ///addresas.
                    AddSalesFormfield(
                      labelText: "Address",
                      height: 40,
                      controller: _addressController,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Container(
                      height: 40,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                        border: Border.all(
                            color: Colors.grey.shade300, width: 0.5), // Border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1), // Light shadow
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1), // Shadow position
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _pickDate(context),
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
                            border:
                                InputBorder.none, // Remove default underline
                          ),
                          child: Text(
                            formattedDate.isNotEmpty
                                ? formattedDate
                                : "No Date Provided",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                 

                   

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //logo
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
                              "Image",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ///save button.
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final provider =
                        Provider.of<BillPersonProvider>(context, listen: false);

                    debugPrint(
                        "date : ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}");

                    // ✅ Format date inline
                    String formattedDate =
                        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

                    debugPrint("date : $formattedDate");

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userId = prefs.getInt('user_id')?.toString();

                    // ✅ Validation check
                    if (_nameController.text.isEmpty ||
                        _nickNameController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Add required field."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // ⛔ Prevent further execution
                    }

                    final success = await provider.createBillPerson(
                      userId: userId!,
                      name: _nameController.text,
                      nickName: _nickNameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      designation: selectedDesignationId.toString(),
                      address: _addressController.text,
                      date: formattedDate,
                      status: selectedStatus,
                      avatarFile:
                          _imageFile != null ? File(_imageFile!.path) : null,
                    );

                    if (success) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BillPersonList()));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Bill Person Created Successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage),
                          backgroundColor: Colors.red,
                        ),
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
                  child: const Text("Save Bill Person",
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ));
  }

  ///image pick up.
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
}
