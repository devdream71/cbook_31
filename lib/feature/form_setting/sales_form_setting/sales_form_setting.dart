 
import 'package:flutter/material.dart';
 
import 'package:shared_preferences/shared_preferences.dart';

class SaleFormSettingsPage extends StatefulWidget {
  const SaleFormSettingsPage({super.key});

  @override
  State<SaleFormSettingsPage> createState() => _SaleFormSettingsPageState();
}

class _SaleFormSettingsPageState extends State<SaleFormSettingsPage> {
  bool _isSwitchedCategory = false;
  bool _isSwitchedPrice = false;
  bool _isSwitchedCategoryPrice = false;
  bool _isStataus = false;
  bool _isSwitchedQtyPrice = false;
  bool _isLoading = true; // NEW: Loading flag

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSwitchedCategory = prefs.getBool('isSwitchedCategory') ?? false;
      _isSwitchedPrice = prefs.getBool('isSwitchedPrice') ?? false;
      _isSwitchedCategoryPrice = prefs.getBool('isSwitchedCategoryPrice') ?? false;
      _isStataus = prefs.getBool('isStatus') ?? false;
      _isSwitchedQtyPrice = prefs.getBool('isSwitchedQtyPrice') ?? false;
      _isLoading = false; // Loading done
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitchedCategory', _isSwitchedCategory);
    prefs.setBool('isSwitchedPrice', _isSwitchedPrice);
    prefs.setBool('isSwitchedCategoryPrice', _isSwitchedCategoryPrice);
    prefs.setBool('isStatus', _isStataus);
    prefs.setBool('isSwitchedQtyPrice', _isSwitchedQtyPrice);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // <-- Show loading
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales From Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Activation Switch",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Now your switches

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable Default Cash",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _isSwitchedCategory,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedCategory = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable Categories & Sub Categories",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _isSwitchedPrice,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedPrice = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable Item Base Unit & Secoundary Unit Show",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _isSwitchedCategoryPrice,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedCategoryPrice = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

             

             
          ],
        ),
      ),
    );
  }
}











// class SalesFormSetting extends StatefulWidget {
//   const SalesFormSetting({super.key});

//   @override
//   SalesFormSettingState createState() => SalesFormSettingState();
// }

// class SalesFormSettingState extends State<SalesFormSetting> {
//   // TextEditingController for managing the text field content

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => SalesController(),
//       builder: (context, child) => const _Layout(),
//     );
//   }
// }

// class _Layout extends StatefulWidget {
//   const _Layout();

//   @override
//   State<_Layout> createState() => _LayoutState();
// }

// class _LayoutState extends State<_Layout> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   void _onCancel() {
//     Navigator.pop(context);
//   }

//   String cashCreditGroup = "Default Cash";
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final controller = context.watch<SalesController>();
//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       appBar: AppBar(
//         backgroundColor: colorScheme.primary,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(
//             Icons.arrow_back,
//             color: colorScheme.surface,
//           ),
//         ),
//         centerTitle: true,
//         title: Center(
//           child: Text(
//             "Sales Form Setting",
//             style: GoogleFonts.lato(
//               color: colorScheme.surface,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(2.0),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: colorScheme.primary.withOpacity(0.1),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Wrap(
//                           spacing: 10,
//                           runSpacing: 10,
//                           children: [
//                             buildToggleOption(
//                               "Default Cash",
//                               "Default Cash",
//                               isSelected: cashCreditGroup == "Default Cash",
//                               onTap: () {
//                                 setState(() {
//                                   cashCreditGroup =
//                                       (cashCreditGroup == "Default Cash"
//                                           ? null
//                                           : "Default Cash")!;

//                                   controller.updateCashForDefaultSet();
//                                 });
//                               },
//                             ),
//                             buildToggleOption(
//                               "Default Credit",
//                               "Default Credit",
//                               isSelected: cashCreditGroup == "Default Credit",
//                               onTap: () {
//                                 setState(() {
//                                   cashCreditGroup =
//                                       (cashCreditGroup == "Default Credit"
//                                           ? null
//                                           : "Default Credit")!;
//                                   controller.updateCreditForDefaultSet();
//                                 });
//                               },
//                             ),
//                             // Individual selections for other options
//                             buildToggleOption(
//                               "Amount",
//                               "Amount",
//                               isSelected: controller.isAmount,
//                               onTap: () {
//                                 controller.updateIsAmount();
//                               },
//                             ),
//                             buildToggleOption(
//                               "Discount",
//                               "Discount",
//                               isSelected: controller.isDisocunt,
//                               onTap: () {
//                                 controller.updateIsDiscount();
//                               },
//                             ),
//                             buildToggleOption(
//                               "Receipt Type",
//                               "Receipt Type",
//                               isSelected: controller.isReciptType,
//                               onTap: () {
//                                 controller.updateIsReciptType();
//                               },
//                             ),
//                             buildToggleOption(
//                               "Additional Cost",
//                               "Additional Cost",
//                               isSelected: controller.isAdditionalCost,
//                               onTap: () {
//                                 controller.updateIsAdditionalCost();
//                               },
//                             ),
//                             buildToggleOption(
//                               "Subtotal",
//                               "Subtotal",
//                               isSelected: controller.isSubTotoal,
//                               onTap: () {
//                                 controller.updateIsSubTotal();
//                               },
//                             ),
//                             buildToggleOption(
//                               "Received Money",
//                               "Received Money",
//                               isSelected: controller.isRecivedMoney,
//                               onTap: () {
//                                 controller.updateIsRecivedMoney();
//                               },
//                             ),

//                             buildToggleOption(
//                               "Return",
//                               "Return",
//                               isSelected: controller.isReturn,
//                               onTap: () {
//                                 controller.updateIsReturn();
//                               },
//                             ),

//                             controller.isCash == false
//                                 ? buildToggleOption(
//                                     "Bill Recipt",
//                                     "Bill Recipt",
//                                     isSelected: controller.isBillRecipt,
//                                     onTap: () {
//                                       controller.updateIsBillRecipt();
//                                     },
//                                   )
//                                 : const SizedBox.shrink(),

//                             controller.isCash == false
//                                 ? buildToggleOption(
//                                     "Previous Recipt",
//                                     "Previous Recipt",
//                                     isSelected: controller.isPreviousRecipt,
//                                     onTap: () {
//                                       controller.updateIsPreviousRecipt();
//                                     },
//                                   )
//                                 : const SizedBox.shrink(),
//                             controller.isCash == false
//                                 ? buildToggleOption(
//                                     "Advance",
//                                     "Advance",
//                                     isSelected: controller.isAdvance,
//                                     onTap: () {
//                                       controller.updateIsAdvance();
//                                     },
//                                   )
//                                 : const SizedBox.shrink(),

//                             controller.isCash == false
//                                 ? buildToggleOption(
//                                     "Bill Total",
//                                     "Bill Total",
//                                     isSelected: controller.isBillTotal,
//                                     onTap: () {
//                                       controller.updateIsBillTotal();
//                                     },
//                                   )
//                                 : const SizedBox.shrink(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Divider(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 controller.updateCash();
//                               },
//                               child: DecoratedBox(
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 5),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         controller.isCash ? "Cash" : "Credit",
//                                         style: GoogleFonts.lato(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14),
//                                       ),
//                                       const SizedBox(width: 1),
//                                       const Icon(
//                                         Icons.arrow_forward_ios,
//                                         color: Colors.white,
//                                         size: 12,
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             const Text(
//                               "Bill To",
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12),
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             const Text(
//                               "Cash/Business/Customer Name",
//                               style:
//                                   TextStyle(color: Colors.black, fontSize: 12),
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   height: 25,
//                                   width: 180,
//                                   // Adjusted height for cursor visibility
//                                   child: controller.isCash
//                                       ? TextField(
//                                           onTap: () {
//                                             showDialog(
//                                               context: context,
//                                               builder: (context) => Dialog(
//                                                 child: ReusableForm(
//                                                   nameController:
//                                                       nameController,
//                                                   phoneController:
//                                                       phoneController,
//                                                   emailController:
//                                                       emailController,
//                                                   addressController:
//                                                       addressController,
//                                                   primaryColor:
//                                                       Theme.of(context)
//                                                           .primaryColor,
//                                                   onCancel: _onCancel,
//                                                   onSubmit: () {
//                                                     setState(() {
//                                                       controller
//                                                           .updatedCustomerInfomation(
//                                                         nameFrom:
//                                                             nameController.text,
//                                                         phoneFrom:
//                                                             phoneController
//                                                                 .text,
//                                                         emailFrom:
//                                                             emailController
//                                                                 .text,
//                                                         addressFrom:
//                                                             addressController
//                                                                 .text,
//                                                       );
//                                                     });
//                                                     Navigator.pop(context);
//                                                   },
//                                                 ),
//                                               ),
//                                             );
//                                           },

//                                           controller: controller
//                                               .controller, // Managing text field content
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 12),
//                                           decoration: InputDecoration(
//                                             // filled: true,
//                                             fillColor: Colors.white,
//                                             border: UnderlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(0),
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.2),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             enabledBorder: UnderlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(0),
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.2),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             focusedBorder: UnderlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(0),
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.2),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                               vertical: 12,
//                                               horizontal: 2,
//                                             ),
//                                           ),
//                                           cursorHeight:
//                                               12, // Adjusted cursor height
//                                           cursorWidth:
//                                               2, // Adjusted cursor width for visibility
//                                         )
//                                       : CreditDropdown(
//                                           value:
//                                               "Customer 1", // Initial selected value
//                                           items: const [
//                                             DropdownMenuItem(
//                                               value: "Customer 1",
//                                               child: Text("Customer 1"),
//                                             ),
//                                             DropdownMenuItem(
//                                               value: "Customer 2",
//                                               child: Text("Customer 2"),
//                                             ),
//                                             DropdownMenuItem(
//                                               value: "Customer 3",
//                                               child: Text("Customer 3"),
//                                             ),
//                                           ],
//                                           onChanged: (value) {
//                                             debugPrint(
//                                                 "Selected: $value"); // Handle the selection
//                                           },
//                                           hintText: "Select Customer",
//                                           hintStyle: TextStyle(
//                                               color: Colors.grey.shade400,
//                                               fontSize: 12),
//                                           borderColor: Colors.grey.shade300,
//                                           height: 30,
//                                           width: 200,
//                                         ),
//                                 ),
//                                 const SizedBox(
//                                     width:
//                                         3), // Space between TextField and Icon
//                                 InkWell(
//                                   onTap: () {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         backgroundColor: colorScheme.primary,
//                                         duration: const Duration(seconds: 1),
//                                         content: const Text(
//                                           'Fetch Successfully',
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: const Icon(
//                                     Icons.sync,
//                                     size: 18,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             nameController.value.text == ""
//                                 ? const SizedBox.shrink()
//                                 : Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text("Name: ${controller.customerName}",
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 10)),
//                                       Text("Phone: ${controller.phone}",
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 10)),
//                                     ],
//                                   ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             // Bill No Field
//                             SizedBox(
//                               height: 25,
//                               width: 90,
//                               child: TextField(
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 12,
//                                 ),
//                                 cursorHeight:
//                                     12, // Match cursor height to text size
//                                 decoration: InputDecoration(
//                                   isDense: true, // Ensures the field is compact
//                                   contentPadding: EdgeInsets
//                                       .zero, // Removes unnecessary padding
//                                   hintText: "Bill no",
//                                   hintStyle: TextStyle(
//                                     color: Colors.grey.shade400,
//                                     fontSize: 10,
//                                   ),
//                                   enabledBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       color: Colors.grey.shade400,
//                                       width: 0.5,
//                                     ),
//                                   ),
//                                   focusedBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       color: Colors.grey.shade400,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             SizedBox(
//                               height: 25,
//                               width: 90,
//                               child: InkWell(
//                                 onTap: () => controller.pickDate(
//                                     context), // Trigger the date picker
//                                 child: InputDecorator(
//                                   decoration: InputDecoration(
//                                     isDense: true,
//                                     suffixIcon: Icon(
//                                       Icons.calendar_today,
//                                       size: 16,
//                                       color: Theme.of(context).primaryColor,
//                                     ),
//                                     suffixIconConstraints: const BoxConstraints(
//                                       minWidth: 16,
//                                       minHeight: 16,
//                                     ), // Adjust constraints to align icon closely
//                                     hintText: "Bill Date",
//                                     hintStyle: TextStyle(
//                                       color: Colors.grey.shade400,
//                                       fontSize: 10,
//                                     ),
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.grey.shade400,
//                                           width: 0.5),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.grey.shade400),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     controller.formattedDate.isNotEmpty
//                                         ? controller.formattedDate
//                                         : "Select Date", // Default text when no date is selected
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             // Bill Time Field
//                             SizedBox(
//                               height: 25,
//                               width: 90,
//                               child: InkWell(
//                                 onTap: () => controller.pickTime(context),
//                                 child: InputDecorator(
//                                   decoration: InputDecoration(
//                                     suffixIconConstraints: const BoxConstraints(
//                                       minWidth: 16,
//                                       minHeight: 16,
//                                     ),
//                                     isDense: true,
//                                     suffixIcon: Icon(
//                                       Icons.timer,
//                                       size: 16,
//                                       color: Theme.of(context).primaryColor,
//                                     ),
//                                     hintText: "Bill Time",
//                                     hintStyle: TextStyle(
//                                         color: Colors.grey.shade400,
//                                         fontSize: 10),
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.grey.shade400,
//                                           width: 0.5),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.grey.shade400),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     controller.formattedTime,
//                                     style: const TextStyle(
//                                         color: Colors.black, fontSize: 12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                   vPad10,
//                   controller.isCash
//                       ? controller.itemsCash.isEmpty
//                           ? Container(
//                               decoration: BoxDecoration(
//                                 color: colorScheme.primary,
//                                 borderRadius: BorderRadius.circular(5),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       "Products",
//                                       style: TextStyle(
//                                           color: Colors.white, fontSize: 14),
//                                     ),
//                                     InkWell(
//                                       onTap: () {
//                                         showSalesDialog(context, controller);
//                                       },
//                                       child: const Icon(
//                                         Icons.add,
//                                         color: Colors.white,
//                                         size: 18,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           : const SizedBox.shrink()
//                       : controller.itemsCredit.isEmpty
//                           ? Container(
//                               decoration: BoxDecoration(
//                                 color: colorScheme.primary,
//                                 borderRadius: BorderRadius.circular(5),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       "Products",
//                                       style: TextStyle(
//                                           color: Colors.white, fontSize: 12),
//                                     ),
//                                     InkWell(
//                                       onTap: () {
//                                         showSalesDialog(context, controller);
//                                       },
//                                       child: const Icon(
//                                         Icons.add,
//                                         color: Colors.white,
//                                         size: 18,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )
//                           : const SizedBox.shrink(),

//                   vPad20,
//                   controller.isCash
//                       ? Expanded(
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 controller.itemsCash.isEmpty
//                                     ? const SizedBox.shrink()
//                                     : Column(
//                                         children: List.generate(
//                                             controller.itemsCash.length,
//                                             (index) {
//                                           final item =
//                                               controller.itemsCash[index];
//                                           return Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 3),
//                                             child: Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: DecoratedBox(
//                                                       decoration: BoxDecoration(
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withOpacity(
//                                                                       0.1),
//                                                               blurRadius: 5,
//                                                               offset:
//                                                                   const Offset(
//                                                                       0, 2),
//                                                             ),
//                                                           ],
//                                                           color: const Color(
//                                                               0xffe1e5f8),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(5)),
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(3),
//                                                         child: Row(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   "${item.itemName!} ${item.category!}",
//                                                                   style: const TextStyle(
//                                                                       color: Colors
//                                                                           .black,
//                                                                       fontSize:
//                                                                           14),
//                                                                 ),
//                                                                 Text(
//                                                                   "${item.itemCode!}  MRP ${item.mrp!}",
//                                                                   style: const TextStyle(
//                                                                       color: Colors
//                                                                           .black38,
//                                                                       fontSize:
//                                                                           12),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             Text(
//                                                               "${item.quantity!}pc x ${item.mrp!} = ${item.total!}",
//                                                               style: const TextStyle(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize: 12),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       )),
//                                                 ),
//                                                 const SizedBox(
//                                                   width: 2,
//                                                 ),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     showDialog(
//                                                       context: context,
//                                                       builder: (BuildContext
//                                                           dialogContext) {
//                                                         return AlertDialog(
//                                                           title: const Text(
//                                                               "Remove Item"),
//                                                           content: const Text(
//                                                             "Are you sure you want to remove this item?",
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black),
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               onPressed: () {
//                                                                 Navigator.pop(
//                                                                     dialogContext); // Close the dialog
//                                                               },
//                                                               child: const Text(
//                                                                   "Cancel"),
//                                                             ),
//                                                             ElevatedButton(
//                                                               onPressed: () {
//                                                                 controller
//                                                                     .removeCashItem(
//                                                                         index); // Perform the removal action
//                                                                 Navigator.pop(
//                                                                     dialogContext); // Close the dialog
//                                                               },
//                                                               style: ElevatedButton.styleFrom(
//                                                                   backgroundColor:
//                                                                       colorScheme
//                                                                           .primary),
//                                                               child: const Text(
//                                                                 "Remove",
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .white),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         );
//                                                       },
//                                                     );
//                                                   },
//                                                   child: Icon(
//                                                     Icons.cancel,
//                                                     color: colorScheme.primary,
//                                                     size: 18,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           );
//                                         }),
//                                       ),
//                                 controller.itemsCash.isEmpty
//                                     ? const SizedBox()
//                                     : vPad10,
//                                 controller.itemsCash.isNotEmpty
//                                     ? Container(
//                                         decoration: BoxDecoration(
//                                           color: colorScheme.primary,
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color:
//                                                   Colors.black.withOpacity(0.2),
//                                               blurRadius: 5,
//                                               offset: const Offset(0, 3),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               const Text(
//                                                 "Products",
//                                                 style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 12),
//                                               ),
//                                               InkWell(
//                                                 onTap: () {
//                                                   showSalesDialog(
//                                                       context, controller);
//                                                 },
//                                                 child: const Icon(
//                                                   Icons.add,
//                                                   color: Colors.white,
//                                                   size: 18,
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     : const SizedBox.shrink()
//                               ],
//                             ),
//                           ),
//                         )
//                       : const SizedBox.shrink(),

//                   controller.isCash == false
//                       ? Expanded(
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 controller.itemsCredit.isEmpty
//                                     ? const SizedBox.shrink()
//                                     : Column(
//                                         children: List.generate(
//                                             controller.itemsCredit.length,
//                                             (index) {
//                                           final item =
//                                               controller.itemsCredit[index];
//                                           return Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 3),
//                                             child: Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: DecoratedBox(
//                                                       decoration: BoxDecoration(
//                                                           color: const Color(
//                                                               0xffe1e5f8),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(5)),
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(3),
//                                                         child: Row(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   "${item.itemName!} ${item.category!}",
//                                                                   style: const TextStyle(
//                                                                       color: Colors
//                                                                           .black,
//                                                                       fontSize:
//                                                                           14),
//                                                                 ),
//                                                                 Text(
//                                                                   "${item.itemCode!}  MRP ${item.mrp!}",
//                                                                   style: const TextStyle(
//                                                                       color: Colors
//                                                                           .black38,
//                                                                       fontSize:
//                                                                           12),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             Text(
//                                                               "${item.quantity!}pc x ${item.mrp!} = ${item.total!}",
//                                                               style: const TextStyle(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize: 12),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       )),
//                                                 ),
//                                                 hPad2,
//                                                 InkWell(
//                                                   onTap: () {
//                                                     showDialog(
//                                                       context: context,
//                                                       builder: (BuildContext
//                                                           dialogContext) {
//                                                         return AlertDialog(
//                                                           title: const Text(
//                                                               "Remove Item"),
//                                                           content: const Text(
//                                                             "Are you sure you want to remove this item?",
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black),
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               onPressed: () {
//                                                                 Navigator.pop(
//                                                                     dialogContext); // Close the dialog
//                                                               },
//                                                               child: const Text(
//                                                                   "Cancel"),
//                                                             ),
//                                                             ElevatedButton(
//                                                               onPressed: () {
//                                                                 controller
//                                                                     .removeCreditItem(
//                                                                         index); // Perform the removal action
//                                                                 Navigator.pop(
//                                                                     dialogContext); // Close the dialog
//                                                               },
//                                                               style: ElevatedButton.styleFrom(
//                                                                   backgroundColor:
//                                                                       colorScheme
//                                                                           .primary),
//                                                               child: const Text(
//                                                                 "Remove",
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .white),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         );
//                                                       },
//                                                     );
//                                                   },
//                                                   child: Icon(
//                                                     Icons.cancel,
//                                                     color: colorScheme.primary,
//                                                     size: 18,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           );
//                                         }),
//                                       ),
//                                 controller.itemsCredit.isEmpty
//                                     ? const SizedBox()
//                                     : vPad10,
//                                 controller.itemsCredit.isNotEmpty
//                                     ? Container(
//                                         decoration: BoxDecoration(
//                                           color: colorScheme.primary,
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color:
//                                                   Colors.black.withOpacity(0.2),
//                                               blurRadius: 5,
//                                               offset: const Offset(0, 3),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               const Text(
//                                                 "Products",
//                                                 style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 12),
//                                               ),
//                                               InkWell(
//                                                 onTap: () {
//                                                   showSalesDialog(
//                                                       context, controller);
//                                                 },
//                                                 child: const Icon(
//                                                   Icons.add,
//                                                   color: Colors.white,
//                                                   size: 18,
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     : const SizedBox.shrink(),
//                               ],
//                             ),
//                           ),
//                         )
//                       : const SizedBox.shrink(),

//                   //bottom button portion

//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: FieldPortion(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           vPad20,
//             //BottomPortion(saleType: controller.isCash ? "Cash" : "Credit",),
//         ],
//       ),
//     );
//   }

//   Widget buildToggleOption(
//     String value,
//     String label, {
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         // padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: isSelected
//               ? colorScheme.primary
//               : colorScheme.primary.withOpacity(0.1),
//           border: Border.all(
//             color: isSelected ? colorScheme.primary : Colors.grey,
//             width: 1,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 height: 10,
//                 width: 20,
//                 child: Radio<String>(
//                   value: value,
//                   groupValue: isSelected ? value : null,
//                   onChanged: (val) => onTap(),
//                   activeColor: Colors.white,
//                 ),
//               ),
//               const SizedBox(
//                 width: 3,
//               ),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isSelected ? Colors.white : Colors.black,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void showSalesDialog(BuildContext context, SalesController controller) {
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;
//     showDialog(
//         context: context,
//         builder: (context) => Dialog(
//             backgroundColor: Colors.grey.shade400,
//             child: Container(
//               // width: double.infinity,
//               height: 460,
//               decoration: BoxDecoration(
//                 color: const Color(0xffe7edf4),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Icon(
//                               Icons.cancel,
//                               size: 15,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                         vPad10,
//                         AnimatedDropdown(
//                           labelText: 'Warehouse',
//                           hintText: 'Select warehouse',
//                           items: controller.warehouse,
//                           initialValue: controller.selectedWarehouse,
//                           onChanged: (value) {
//                             controller.updateWarehouse(value);
//                           },
//                         ),

//                         vPad8,
//                         // Category and Subcategory Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Category Dropdown
//                             Expanded(
//                               flex: 4,
//                               child: AnimatedDropdown(
//                                 labelText: 'Category',
//                                 hintText: 'Select Category',
//                                 items: controller.category,
//                                 initialValue: controller.selectedCategory,
//                                 onChanged: (value) {
//                                   controller.updateCategory(value);
//                                 },
//                               ),
//                             ),
//                             hPad10,

//                             // Subcategory Dropdown
//                             Expanded(
//                               flex: 4,
//                               child: AnimatedDropdown(
//                                 labelText: 'Sub Category',
//                                 hintText: 'Select Sub Category',
//                                 items: controller.subCategory,
//                                 initialValue: controller.selectedSubCategory,
//                                 onChanged: (value) {
//                                   controller.updateSubCategory(value);
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),

//                         vPad5,
//                         AnimatedDropdown(
//                           labelText: 'Item Name',
//                           hintText: 'Select Item Name',
//                           items: controller.itemName,
//                           initialValue: controller.seletedItemName,
//                           onChanged: (value) {
//                             controller.updateItemName(value);
//                           },
//                         ),

//                         vPad5,
//                         Row(
//                           children: [
//                             Expanded(
//                               child: AddSalesFormfield(
//                                 label: "Code",
//                                 controller: controller.codeController,
//                               ),
//                             ),
//                             hPad10,
//                             Expanded(
//                               child: AddSalesFormfield(
//                                 label: "MPR",
//                                 controller: controller.mrpController,
//                               ),
//                             ),
//                           ],
//                         ),
//                         vPad5,
//                         Row(
//                           children: [
//                             Expanded(
//                               child: AddSalesFormfield(
//                                 label: "Qty",
//                                 controller: controller.qtyController,
//                               ),
//                             ),
//                             hPad10,
//                             Expanded(
//                               child: AddSalesFormfield(
//                                 label: "Unit",
//                                 controller: controller.unitController,
//                               ),
//                             ),
//                           ],
//                         ),
//                         vPad5,
//                         Row(
//                           children: [
//                             Expanded(
//                               child: AddSalesFormfield(
//                                 label: "Price",
//                                 controller: controller.priceController,
//                               ),
//                             ),
//                             hPad10,
//                             Expanded(
//                               child: AddSalesFormfield(
//                                 label: "Amount",
//                                 controller: controller.amountController,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Align(
//                       alignment: Alignment.bottomRight,
//                       child: InkWell(
//                         onTap: () {
//                           debugPrint("Add Item");

//                           controller.isCash
//                               ? controller.addCashItem()
//                               : controller.addCreditItem();
//                           // debugPrint(controller.items.length.toString());
//                           Navigator.pop(context);
//                         },
//                         child: DecoratedBox(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: colorScheme.primary,
//                             ),
//                             child: const Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 6.0, vertical: 2),
//                               child: Text(
//                                 "Ok",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 14),
//                               ),
//                             )),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             )));
//   }
// }

// class ItemModel {
//   final String? category;
//   final String? subCategory;
//   final String? itemName;
//   final String? itemCode;
//   final String? mrp;
//   final String? quantity;
//   final String? total;
//   ItemModel({
//     this.category,
//     this.subCategory,
//     this.itemName,
//     this.itemCode,
//     this.mrp,
//     this.quantity,
//     this.total,
//   });
// }
