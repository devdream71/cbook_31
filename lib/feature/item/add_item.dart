import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/add_unit.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/category/item_category_list.dart';
import 'package:cbook_dt/feature/category/sub_category/sub_category_list.dart';
import 'package:cbook_dt/feature/item/item_settings_page.dart';
import 'package:cbook_dt/feature/item/multiprice_two.dart';
import 'package:cbook_dt/feature/item/multipul_price.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/item_save_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/unit/unit_list.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;

  bool _isPriceLevelEnabled = false; // From Settings
  bool _isDefaultPriceChecked = false; // For Checkbox

  bool _isCategoryEnabled = false;

  bool _isSwitchedCategoryPrice =
      false; // Enable/Disable Price Category Switch from Settings
  bool _isPriceCategory = false; // For Checkbox

  bool _isPriceQTYPriceEnable = false;

  bool _isQTYPriceChecked = false;

  bool _isStatusEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Future.microtask(() {
      final controller = Provider.of<SalesController>(context, listen: false);
      controller.clearUnitSelection();

      controller.salesControllerAS();

      controller.clearSalesFields();

      // this will trigger notifyListeners
    });

    _loadSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPriceLevelEnabled = prefs.getBool('isSwitchedPrice') ?? false;
      _isCategoryEnabled = prefs.getBool('isSwitchedCategory') ?? false;
      _isSwitchedCategoryPrice =
          prefs.getBool('isSwitchedCategoryPrice') ?? false;
      _isPriceQTYPriceEnable = prefs.getBool('isSwitchedQtyPrice') ?? false;
      _isStatusEnabled = prefs.getBool('isStatus') ?? false;
    });
  }

  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // String? selectedValue = 'No';
  String selectedStatus = "1"; // Default status

  TextEditingController salePriceController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController mrpPriceController = TextEditingController();

  // List to store TextEditingController for each row
  List<Map<String, TextEditingController>> _textControllers = [];

  void _addRow() {
    setState(() {
      // Add a new map for qty and price controllers to the list
      _textControllers.add({
        'qty': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final controller = Provider.of<SalesController>(context);
    final categoryProvider = Provider.of<ItemCategoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Item",
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ItemSettingsPage()),
                ).then((_) {
                  _loadSettings(); // Reload settings when coming back
                });

                FocusScope.of(context).unfocus();
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ///item
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AddItem()),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      // border: Border.all(color: Colors.green),
                                      // borderRadius: BorderRadius.circular(6)
                                      ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.developer_board,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "New Item",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              ///unit
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const UnitListView()),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      // border: Border.all(color: Colors.green),
                                      // borderRadius: BorderRadius.circular(6)
                                      ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Unit",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              ///category view
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ItemCategoryView()),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      //border: Border.all(color: Colors.green),
                                      //borderRadius: BorderRadius.circular(6)
                                      ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Category",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),

                              ///subcategory
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ItemSubCategoryView()),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      // border: Border.all(color: Colors.green),
                                      // borderRadius: BorderRadius.circular(6)
                                      ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.mediation,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Sub Category",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),

                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),

                        vPad10,

                        ///item text form start.

                        AddSalesFormfield(
                          labelText: 'Item Name',
                          height: 40,
                          controller: controller.nameAddItemController,
                        ),

                        ///unit selected///
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                // Check if secondary unit is selected and different from base unit
                                if (controller.selectedUnit2 != null &&
                                    controller.selectedUnit2!.isNotEmpty &&
                                    controller.selectedUnit2 !=
                                        controller.selectedUnit) ...[
                                  vPad5,
                                  Row(
                                    children: [
                                      Text(
                                        "1 ${controller.selectedUnit} = ",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          controller.conversionRate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            //fontWeight: FontWeight.normal
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " ${controller.selectedUnit2}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          //fontWeight: FontWeight.normal
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                                // If no secondary unit is selected, show the base unit only
                                else if (controller.selectedUnit != null &&
                                    controller.selectedUnit!.isNotEmpty) ...[
                                  vPad5,
                                  Row(
                                    children: [
                                      Text(
                                        "${controller.selectedUnit}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ]
                                // If no unit is selected at all, show "Not Selected"
                                else ...[
                                  vPad5,
                                  const Text(
                                    // "Base Unit: Not Selected",
                                    "",

                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                ],
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (BuildContext context) {
                                      return DraggableScrollableSheet(
                                        expand: false,
                                        initialChildSize: 0.45,
                                        minChildSize: 0.35,
                                        maxChildSize: 0.85,
                                        builder: (context, scrollController) {
                                          return Container(
                                            padding: EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 16,
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                            ),
                                            child: SingleChildScrollView(
                                              controller:
                                                  scrollController, // <-- Attach the scrollController
                                              child: SelectUnitBottomSheet(
                                                selectedUnit:
                                                    controller.selectedUnit,
                                                selectedUnit2:
                                                    controller.selectedUnit2,
                                                conversionRateController:
                                                    controller
                                                        .conversionRateController,
                                                onUnit1Changed: (value) {
                                                  controller.updateUnit1(value);
                                                },
                                                onUnit2Changed: (value) {
                                                  controller.updateUnit2(value);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: const Text("Selected Unit"),
                              ),
                            ),
                          ],
                        ),

                        vPad5,

                        if (_isCategoryEnabled)
                          Row(
                            children: [
                              // CATEGORY Dropdown
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Category",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: categoryProvider.isLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          )
                                        : CustomDropdownTwo(
                                            items: categoryProvider.categories
                                                .map(
                                                    (category) => category.name)
                                                .toList(),
                                            hint: '',
                                            width: double.infinity,
                                            height: 40,
                                            onChanged: (value) {
                                              final selectedCategory =
                                                  categoryProvider.categories
                                                      .firstWhere((cat) =>
                                                          cat.name == value);

                                              setState(() {
                                                selectedCategoryId =
                                                    selectedCategory.id;
                                                selectedSubCategoryId = null;
                                              });

                                              categoryProvider
                                                  .fetchSubCategories(
                                                      selectedCategory.id);
                                            },
                                          ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 10),

                              // SUBCATEGORY Dropdown
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: categoryProvider.isSubCategoryLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          )
                                        : categoryProvider
                                                .subCategories.isNotEmpty
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Sub Category",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  CustomDropdownTwo(
                                                    items: categoryProvider
                                                        .subCategories
                                                        .map((subCategory) =>
                                                            subCategory.name)
                                                        .toList(),
                                                    hint: '',
                                                    width: double.infinity,
                                                    height: 40,
                                                    onChanged: (value) {
                                                      final selectedSubCategory =
                                                          categoryProvider
                                                              .subCategories
                                                              .firstWhere(
                                                                  (subCat) =>
                                                                      subCat
                                                                          .name ==
                                                                      value);

                                                      setState(() {
                                                        selectedSubCategoryId =
                                                            selectedSubCategory
                                                                .id;
                                                      });
                                                      debugPrint(
                                                          "Selected SubCategory: $selectedSubCategoryId");
                                                    },
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),

                        ////=======>category and subcategory = if setting enable then show.

                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: "Opening Stock",
                                height: 40,
                                controller: controller.stockAddItemController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            hPad10,
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: 'Price',
                                height: 40,
                                controller: controller.priceAddItemController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AddSalesFormfield(
                                labelText: 'Value',
                                height: 40,
                                controller: controller.valueAddItemController,
                                onChanged: (value) {},
                              ),
                            ),
                            hPad10,
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
                                      onTap: () => controller.pickDate(context),
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
                          height: 5,
                        ),

                        //////==================> Status , is status enable in settings then show

                        if (_isStatusEnabled) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Status",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomDropdownTwo(
                                        items: const [
                                          "Active",
                                          "Inactive"
                                        ], // Display labels
                                        hint: '', // Select Status
                                        width: double.infinity,
                                        height: 30,
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
                              const Expanded(child: SizedBox()),
                            ],
                          )
                        ],

                        const SizedBox(
                          height: 10,
                        ),

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

                        //////===========>Price level , if its enable from settings then show it.
                        const SizedBox(
                          height: 10,
                        ),

                        ///====> price level

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Price Level",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isPriceLevelEnabled) // If Price Level is Enabled from Settings
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isDefaultPriceChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isDefaultPriceChecked =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "Default Price",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  if (_isDefaultPriceChecked)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 50.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 5),
                                          SupplierCustomerPriceTwoPage(), // your price fields
                                        ],
                                      ),
                                    )
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),

                        ///===> price category
                        if (_isSwitchedCategoryPrice) // Check if enabled from Settings
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isPriceCategory,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isPriceCategory = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Price Category",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              if (_isPriceCategory) // Show price fields only if checkbox ticked
                                Padding(
                                  padding: const EdgeInsets.only(left: 50.0),
                                  child: SupplierCustomerPricePage(),
                                ),
                            ],
                          )
                        else
                          const SizedBox
                              .shrink(), // If switch is disabled, show nothing

                        /////qty price
                        ///
                        if (_isPriceQTYPriceEnable) ...[
                          Row(
                            children: [
                              Checkbox(
                                value: _isQTYPriceChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isQTYPriceChecked = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "QTY price",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ],
                          ),
                          if (_isQTYPriceChecked)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 50.0, top: 4),
                              child: Column(
                                children: [
                                  const Text(
                                    "Auto Qty & Price (Only Default Price allow)",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 13),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white),
                                    onPressed: _addRow,
                                    child: const Text("Add"),
                                  ),
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _textControllers.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          // Quantity TextField

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0, right: 5),
                                            child: Text(
                                              "${index + 1}.",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Qty",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: AddSalesFormfield(
                                                  controller: _textControllers[
                                                          index][
                                                      'qty']!, // _textControllers[index]['price']

                                                  keyboardType:
                                                      TextInputType.number,

                                                  onChanged: (qtyValue) {
                                                    final provider = Provider
                                                        .of<ItemProvider>(
                                                            context,
                                                            listen: false);
                                                    final priceValue =
                                                        _textControllers[index]
                                                                    ['price']
                                                                ?.text ??
                                                            '';
                                                    provider.updateQtyPrice(
                                                      index,
                                                      qty: qtyValue,
                                                      price: priceValue,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          const Padding(
                                            padding: EdgeInsets.only(
                                                top: 18.0, left: 8),
                                            child: Text(
                                              ">=",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),

                                          const SizedBox(width: 10),
                                          // Price TextField
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("Price",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              SizedBox(
                                                width: 100,
                                                child: AddSalesFormfield(
                                                  controller:
                                                      _textControllers[index]
                                                          ['price']!,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (priceValue) {
                                                    final provider = Provider
                                                        .of<ItemProvider>(
                                                            context,
                                                            listen: false);
                                                    final qtyValue =
                                                        _textControllers[index]
                                                                    ['qty']
                                                                ?.text ??
                                                            '';
                                                    provider.updateQtyPrice(
                                                      index,
                                                      qty: qtyValue,
                                                      price: priceValue,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _textControllers
                                                      .removeAt(index);
                                                });
                                              },
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],

                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              ///save button .
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: () {
                      //print all price level price
                      final priceData =
                          Provider.of<ItemProvider>(context, listen: false)
                              .priceValues;

                      priceData.forEach((key, value) {
                        debugPrint('$key -> $value');
                      });

                      if (priceData.containsKey('Sale Price')) {
                        debugPrint('Sale Price: ${priceData['Sale Price']}');
                      }

                      if (priceData.containsKey('Purchase Price')) {
                        debugPrint(
                            'Purchase Price: ${priceData['Purchase Price']}');
                      }

                      if (priceData.containsKey('MRP Price')) {
                        debugPrint('MRP Price: ${priceData['MRP Price']}');
                      }

                      ['Sale Price', 'Purchase Price', 'MRP Price']
                          .forEach((label) {
                        if (priceData.containsKey(label)) {
                          debugPrint('$label: ${priceData[label]}');
                        }
                      });

                      //print all category price
                      final categorypriceData =
                          Provider.of<ItemProvider>(context, listen: false)
                              .categoryPriceValues;

                      categorypriceData.forEach((key, value) {
                        debugPrint('$key -> $value');
                      });

                      [
                        'Wholesales',
                        'Dealer',
                        'Retailer',
                        "E-commerce Store",
                        'Depo',
                        'Sub Dealer',
                        'Broker',
                        'Online Store'
                      ].forEach((label) {
                        if (categorypriceData.containsKey(label)) {
                          debugPrint('$label: ${categorypriceData[label]}');
                        }
                      });

                      //print all qty price
                      Provider.of<ItemProvider>(context, listen: false)
                          .printAllQtyPrice();

                      if (controller.nameAddItemController.text
                              .trim()
                              .isEmpty ||
                          controller.priceAddItemController.text
                              .trim()
                              .isEmpty ||
                          controller.stockAddItemController.text
                              .trim()
                              .isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please fill in all required fields, Name, Price, Stock'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Prevent further execution
                      }

                      debugPrint("Unit ");
                      debugPrint(
                          "Conversion Rate: ${controller.conversionRate.isNotEmpty ? controller.conversionRate : 'Not Set'}");
                      debugPrint(
                          "Base Unit ID: ${controller.selectedUnitID ?? 'Not Selected'}");
                      debugPrint(
                          "Secondary Unit ID: ${controller.selectedUnit2ID ?? 'Not Selected'}");
                      debugPrint(
                          "Base Unit: ${controller.selectedUnit ?? 'Not Selected'}");
                      debugPrint(
                          "Secondary Unit: ${controller.selectedUnit2 ?? 'Not Selected'}");

                      debugPrint("selectedCategoryId =============> ");

                      debugPrint("Price =====> ");
                      debugPrint("sale price  ${salePriceController.text}");
                      debugPrint(
                          "purchase price ${purchasePriceController.text}");
                      debugPrint("mrp price  ${mrpPriceController.text}");

                      if (_formKey.currentState?.validate() ?? false) {
                        // Save logic here
                        final provider =
                            Provider.of<ItemProvider>(context, listen: false);

                        // Check if the secondary unit is selected, if not, pass null and a default conversion rate of 1
                        final unitQty = controller.selectedUnit2 != null &&
                                controller.conversionRate.isNotEmpty
                            ? controller.conversionRate
                            : '1'; // If no conversion rate, assume it's 1 (no conversion)

                        final secondaryUnitId = controller.selectedUnit2 !=
                                    null &&
                                controller.selectedUnit2!.isNotEmpty
                            ? int.tryParse(controller.selectedUnit2ID
                                .toString()) // Use the selected ID if available
                            : null; // If no secondary unit selected, pass null

                        provider.saveItem(
                          context,
                          name: controller.nameAddItemController.text,
                          openingDate: controller.formattedDate,
                          status: "1",
                          stock: int.tryParse(
                                  controller.stockAddItemController.text) ??
                              0,
                          price: double.tryParse(
                                  controller.priceAddItemController.text) ??
                              0.0,
                          value: double.tryParse(
                                  controller.valueAddItemController.text) ??
                              0.0,
                          imageFile: _imageFile != null
                              ? File(_imageFile!.path)
                              : null,
                          unitQty: unitQty, // Use the conditional unitQty
                          unitId: int.parse(controller.selectedUnitID!
                              .toString()), // Always pass the base unit
                          secondaryUnitId: secondaryUnitId ??
                              0, // Pass null or the secondary unit ID

                          selectedCategoryId: (selectedCategoryId
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ??
                                  false)
                              ? int.tryParse(
                                      selectedCategoryId.toString().trim()) ??
                                  0
                              : 0,
                          selectedSubCategoryId: (selectedSubCategoryId
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ??
                                  false)
                              ? int.tryParse(selectedSubCategoryId
                                      .toString()
                                      .trim()) ??
                                  0
                              : 0,
                          salePrice: priceData['Sale Price'],
                          purchaePrice:
                              priceData['Purchase Price'], //purchasePrice
                          mrpPrice: priceData['MRP Price'],

                          wholesalessPrice:
                              categorypriceData['wholesaless_price'],
                          dealersPrice: categorypriceData['dealers_price'],
                          retailersPrice: categorypriceData['retailers_price'],
                          brokersPrice: categorypriceData['brokers_price'],
                          ecommercesPrice:
                              categorypriceData['ecommerces_price'],
                        );

                        //Clear all form fields after saving
                        controller.nameAddItemController.clear();
                        controller.stockAddItemController.clear();
                        controller.priceAddItemController.clear();
                        controller.valueAddItemController.clear();

                        controller.selectedStatus = null;
                        controller.selectedUnit = null;
                        controller.selectedUnit2 = null;

                        controller.notifyListeners();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Validation failed!, Pleasae fill Name, Price and Stock",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        debugPrint("Validation failed!");
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
                    child: const Text(
                      "Save Item",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

               const SizedBox(height: 50,)
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
}
