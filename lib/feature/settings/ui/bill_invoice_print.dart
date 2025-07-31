import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillInvoicePrint extends StatefulWidget {
  const BillInvoicePrint({super.key});

  @override
  State<BillInvoicePrint> createState() => _BillInvoicePrintState();
}

class _BillInvoicePrintState extends State<BillInvoicePrint> {
  Map<String, bool> isChecked = {};
  Map<String, TextEditingController> controllers = {};
  Map<String, String?> selectedDropdownValues = {};

  final ImagePicker _picker = ImagePicker();

  XFile? _companyLogoImage;
  XFile? _signatureRightImage;
  XFile? _signatureLeftImage;
  XFile? _signatureMiddleImage;

  final List<String> items = [
    "Bill header", "Header style", "Company name size", "Mobile/phone", "Company Phone Number", "Mail",
    "Company Address", "Company logo", "Bill Person", "Body Watermark", "Body Watermark logo",  "Customer Name", "S.l No", "Item Code",
    "MRP", "Price", "Unit", "Item QTY", "Item Discount Amount", "Item Discount Percentance",
    "Item Discount Amount & Percentance", "Bill Discount Amount", "Bill Discount Percentance",
    "Bill Discount Amount & Percentance", "Item Vat/Tax Amount", "Item Vat/Tax Percentance",
    "Item Vat/Tax Amount & Percentance", "Bill Vat/Tax Amount", "Bill Vat/Tax Percentance",
    "Bill Vat/Tax Amount & Percentance", "Pervious Amount", "Amount in Word", "QR Code", "Narration",
    "QR & Text Footer Text", "Paid Stamp", "Unpaid Stamp", "Terms & Condition", "Signature Right Show", "Signature Right",
    "Signature Left", "Signature Middle", "Signature Right Title", "Signature Left Title",
    "Signature Middle Title", "Print Copy", "Print Copy Shop", "Print Copy Customer"
  ];

  final List<String> noTextFieldItems = [
    "S.l No", "Company Phone Number", "Item Code", "Price", "MRP", "QR Code", "Paid Stamp", "Unit",
    "Customer Name", "Item QTY", "Item Discount Amount", "Item Discount Percentance",
    "Item Discount Amount & Percentance", "Bill Discount Amount", "Bill Discount Percentance",
    "Bill Discount Amount & Percentance", "Item Vat/Tax Amount", "Item Vat/Tax Percentance",
    "Item Vat/Tax Amount & Percentance", "Bill Vat/Tax Amount", "Bill Vat/Tax Percentance",
    "Bill Vat/Tax Amount & Percentance", 'Amount in Word', 'Narration', 'Terms & Condition',
    'Print Copy Shop', "Print Copy Customer", 'Body Watermark logo', "Signature Right Show",
  ];

  final List<String> dropdownOptions = ["Manager", "Account", "Sales Person"];

  @override
  void initState() {
    super.initState();
    for (var item in items) {
      isChecked[item] = false;
      controllers[item] = TextEditingController();
      selectedDropdownValues[item] = null;
    }
    _loadSettings();
  }

 

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAllCheckboxStates() async {
  for (var entry in isChecked.entries) {
    await _saveCheckbox(entry.key, entry.value);
  }
}

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var item in items) {
        isChecked[item] = prefs.getBool('checkbox_$item') ?? false;
        if (!noTextFieldItems.contains(item)) {
          controllers[item]?.text = prefs.getString('text_$item') ?? '';
        }
        selectedDropdownValues[item] = prefs.getString('dropdown_$item');
      }
    });
  }

  Future<void> _saveCheckbox(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkbox_$key', value);
  }

  Future<void> _saveText(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('text_$key', value);
  }

  Future<void> _saveDropdown(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('dropdown_$key');
    } else {
      await prefs.setString('dropdown_$key', value);
    }
  }

  Future<void> _pickImage(ImageSource source, String key) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        switch (key) {
          case "Company logo":
            _companyLogoImage = pickedFile;
            break;
          case "Signature Right":
            _signatureRightImage = pickedFile;
            break;
          case "Signature Left":
            _signatureLeftImage = pickedFile;
            break;
          case "Signature Middle":
            _signatureMiddleImage = pickedFile;
            break;
        }
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context, String key) {
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
                  _pickImage(ImageSource.gallery, key);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, key);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckboxRow(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked[key],
            onChanged: (value) {
              setState(() {
                isChecked[key] = value!;
              });
              _saveCheckbox(key, value!);

              if (value == true && ["Company logo", "Signature Right", "Signature Left", "Signature Middle"].contains(key)) {
                _showImageSourceActionSheet(context, key);
              }
            },
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(
              key,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
          const Spacer(),

          // Image picker if checked
          if (isChecked[key]! && ["Company logo", "Signature Right", "Signature Left", "Signature Middle"].contains(key))
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context, key),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: (() {
                      switch (key) {
                        case "Company logo":
                          return _companyLogoImage != null
                              ? FileImage(File(_companyLogoImage!.path))
                              : const AssetImage("assets/image/cbook_logo.png");
                        case "Signature Right":
                          return _signatureRightImage != null
                              ? FileImage(File(_signatureRightImage!.path))
                              : const AssetImage("assets/image/cbook_logo.png");
                        case "Signature Left":
                          return _signatureLeftImage != null
                              ? FileImage(File(_signatureLeftImage!.path))
                              : const AssetImage("assets/image/cbook_logo.png");
                        case "Signature Middle":
                          return _signatureMiddleImage != null
                              ? FileImage(File(_signatureMiddleImage!.path))
                              : const AssetImage("assets/image/cbook_logo.png");
                        default:
                          return const AssetImage("assets/image/cbook_logo.png");
                      }
                    }()) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(Icons.camera_alt, size: 14, color: Colors.black54),
                  ),
                ),
              ),
            )

          // Dropdown for title if checked
          else if (isChecked[key]! && [
            "Signature Right Title", "Signature Left Title", "Signature Middle Title",
          ].contains(key))
            DropdownButton<String>(
              value: selectedDropdownValues[key],
              hint: const Text("Select"),
              items: dropdownOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDropdownValues[key] = value;
                });
                _saveDropdown(key, value);
              },
            )

          // TextField if checked and allowed
          else if (isChecked[key]! && !noTextFieldItems.contains(key))
            SizedBox(
              width: 150,
              height: 30,
              child: TextField(
                controller: controllers[key],
                style: const TextStyle(color: Colors.black, fontSize: 10),
                decoration: InputDecoration(
                  labelText: key,
                  
                  labelStyle: const TextStyle(fontSize: 12, ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                ),
                onChanged: (val) {
                  _saveText(key, val);
                },
              ),
            ),

          if (!isChecked[key]!) const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: true,
    onPopInvokedWithResult: (bool didPop, dynamic result) async {
      if (didPop) {
        await _loadSettings(); // Save checkbox states before leaving
        // Optionally return a result or perform additional actions
      }
    },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Bill & Invoice Print Setting",
            style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: items.map((item) => _buildCheckboxRow(item)).toList(),
          ),
        ),
      ),
    );
  }
}


 