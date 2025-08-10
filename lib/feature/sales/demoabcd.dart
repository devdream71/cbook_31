// class SalesView extends StatefulWidget {
//   const SalesView({super.key});

//   @override
//   SalesViewState createState() => SalesViewState();
// }

// class SalesViewState extends State<SalesView> {
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
//   TextEditingController customerNameController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   TextEditingController billController = TextEditingController();

//   String? selectedItem;
//   Customer? selectedCustomerObject;
//   int? selectedSubCategoryId;
//   String? selectedCustomer;
//   String? selectedCustomerId;
//   String? selectedItemNameInvoice;
//   List<String> unitIdsList = [];
//   List<double> amount = [];
//   bool showNoteField = false;
//   String? selectedBillPerson;
//   int? selectedBillPersonId;
//   BillPersonModel? selectedBillPersonData;
//   late TextEditingController customerController;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

//     Future.microtask(() =>
//         Provider.of<ItemCategoryProvider>(context, listen: false)
//             .fetchCategories());

//     Provider.of<AddItemProvider>(context, listen: false).fetchItems();

//     Future.microtask(() =>
//         Provider.of<PaymentVoucherProvider>(context, listen: false)
//             .fetchBillPersons());

//     Future.microtask(() async {
//       await fetchAndSetBillNumber();
//     });

//     customerController = TextEditingController();
//   }

//   Future<void> fetchAndSetBillNumber() async {
//     debugPrint('fetchAndSetBillNumber called');

//     final url = Uri.parse(
//       'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=purchase&type=sales&code=SAL&bill_number=100&with_nick_name=1',
//     );

//     debugPrint('API URL: $url');

//     try {
//       debugPrint('Making API call...');
//       final response = await http.get(url);
//       debugPrint('API Response Status: ${response.statusCode}');
//       debugPrint('API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         debugPrint('Parsed data: $data');

//         if (data['success'] == true && data['data'] != null) {
//           String billFromApi = data['data']['bill_number'].toString();
//           debugPrint('Bill from API: $billFromApi');

//           String newBill = billFromApi;
//           debugPrint('New bill after increment: $newBill');

//           if (mounted) {
//             setState(() {
//               billController.text = newBill;
//               debugPrint('Bill controller updated to: ${billController.text}');
//             });
//           }
//         } else {
//           debugPrint('API success false or data null');
//           if (mounted) {
//             setState(() {
//               billController.text = "SAL-100";
//               debugPrint('Set fallback bill: ${billController.text}');
//             });
//           }
//         }
//       } else {
//         debugPrint('Failed to fetch bill number: ${response.statusCode}');
//         if (mounted) {
//           setState(() {
//             billController.text = "SAL-100";
//             debugPrint(
//                 'Set fallback bill due to status code: ${billController.text}');
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching bill number: $e');
//       if (mounted) {
//         setState(() {
//           billController.text = "SAL-100";
//           debugPrint(
//               'Set fallback bill due to exception: ${billController.text}');
//         });
//       }
//     }
//   }

//   void _onCancel() {
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     customerNameController.dispose();
//     nameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     addressController.dispose();
//     searchController.dispose();
//     billController.dispose();
//     customerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final controller = context.watch<SalesController>();

//     // Define invoiceItems before using it in BottomPortion
//     List<InvoiceItem> invoiceItems = controller.itemsCash.map((item) {
//       return InvoiceItem(
//         itemName: item.itemName ?? "",
//         unit: "N/A",
//         quantity: int.tryParse(item.quantity ?? "0") ?? 0,
//         amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
//             (double.tryParse(item.mrp ?? "0") ?? 0.0),
//       );
//     }).toList();

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: AppColors.primaryColor,
//         statusBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.dark,
//       ),
//       child: Container(
//         color: AppColors.primaryColor,
//         child: SafeArea(
//           child: Scaffold(
//             resizeToAvoidBottomInset:
//                 false, // ✅ This prevents keyboard from pushing content
//             backgroundColor: AppColors.sfWhite,
//             appBar: AppBar(
//               backgroundColor: colorScheme.primary,
//               leading: InkWell(
//                 onTap: () {
//                   Provider.of<CustomerProvider>(context, listen: false)
//                       .clearSelectedCustomer();
//                   Navigator.pop(context);
//                 },
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: colorScheme.surface,
//                 ),
//               ),
//               centerTitle: true,
//               title: Text(
//                 "Bill/ Invoice",
//                 style: GoogleFonts.lato(
//                   color: Colors.yellow,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               actions: [
//                 IconButton(
//                     onPressed: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   const BillInvoiceCreateForm()));
//                     },
//                     icon: const Icon(
//                       Icons.settings,
//                       color: Colors.white,
//                     ))
//               ],
//             ),
//             body: 
            
//             GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 FocusScope.of(context).unfocus();
//               },
//               child: Column(
//                 children: [
//                   // ✅ Scrollable content area with fixed height
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Top section - Customer info and bill details
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 flex: 2,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             // Cash/Credit button
//                                             InkWell(
//                                               onTap: () {
//                                                 controller.updateCash(context);
//                                                 Provider.of<CustomerProvider>(
//                                                         context,
//                                                         listen: false)
//                                                     .clearSelectedCustomer();
//                                               },
//                                               child: DecoratedBox(
//                                                 decoration: BoxDecoration(
//                                                   color: AppColors.primaryColor,
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                 ),
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(horizontal: 5),
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       Text(
//                                                         controller.isCash
//                                                             ? "Cash"
//                                                             : "Credit",
//                                                         style: GoogleFonts.lato(
//                                                             color: Colors.white,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontSize: 14),
//                                                       ),
//                                                       const SizedBox(width: 1),
//                                                       const Icon(
//                                                         Icons.arrow_forward_ios,
//                                                         color: Colors.white,
//                                                         size: 12,
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             const Text(
//                                               "Bill To",
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 12),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),

//                                     // Customer section
//                                     const Text(
//                                       "Customer",
//                                       style: TextStyle(
//                                           color: Colors.black, fontSize: 13),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           height: 58,
//                                           width: 180,
//                                           child: controller.isCash
//                                               ? InkWell(
//                                                   onTap: () {
//                                                     showDialog(
//                                                       context: context,
//                                                       builder: (context) =>
//                                                           Dialog(
//                                                         child: ReusableForm(
//                                                           nameController:
//                                                               nameController,
//                                                           phoneController:
//                                                               phoneController,
//                                                           emailController:
//                                                               emailController,
//                                                           addressController:
//                                                               addressController,
//                                                           primaryColor:
//                                                               Theme.of(context)
//                                                                   .primaryColor,
//                                                           onCancel: _onCancel,
//                                                           onSubmit: () {
//                                                             setState(() {
//                                                               controller
//                                                                   .updatedCustomerInfomation(
//                                                                 nameFrom:
//                                                                     nameController
//                                                                         .text,
//                                                                 phoneFrom:
//                                                                     phoneController
//                                                                         .text,
//                                                                 emailFrom:
//                                                                     emailController
//                                                                         .text,
//                                                                 addressFrom:
//                                                                     addressController
//                                                                         .text,
//                                                               );
//                                                             });
//                                                             Navigator.pop(
//                                                                 context);
//                                                           },
//                                                         ),
//                                                       ),
//                                                     );
//                                                   },
//                                                   child: const Text(
//                                                     "Cash",
//                                                     style: TextStyle(
//                                                       color: Colors.blue,
//                                                       fontSize: 12,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ))
//                                               : Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     AddSalesFormfieldTwo(
//                                                       controller: controller
//                                                           .customerNameController,
//                                                       customerorSaleslist:
//                                                           "Showing Customer list",
//                                                       customerOrSupplierButtonLavel:
//                                                           "Add customer",
//                                                       color: Colors.grey,
//                                                       onTap: () {
//                                                         Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                                 builder:
//                                                                     (context) =>
//                                                                         const CustomerCreate()));
//                                                       },
//                                                     ),
//                                                     Consumer<CustomerProvider>(
//                                                       builder: (context,
//                                                           customerProvider,
//                                                           child) {
//                                                         final customerList =
//                                                             customerProvider
//                                                                     .customerResponse
//                                                                     ?.data ??
//                                                                 [];

//                                                         return Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             if (customerList
//                                                                 .isEmpty)
//                                                               const SizedBox(
//                                                                   height: 2),
//                                                             if (customerList
//                                                                 .isNotEmpty)
//                                                               if (customerProvider
//                                                                           .selectedCustomer !=
//                                                                       null &&
//                                                                   customerProvider
//                                                                           .selectedCustomer!
//                                                                           .id !=
//                                                                       -1)
//                                                                 Row(
//                                                                   children: [
//                                                                     Text(
//                                                                       "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             10,
//                                                                         fontWeight:
//                                                                             FontWeight.bold,
//                                                                         color: customerProvider.selectedCustomer!.type ==
//                                                                                 'customer'
//                                                                             ? Colors.green
//                                                                             : Colors.red,
//                                                                       ),
//                                                                     ),
//                                                                     Padding(
//                                                                       padding: const EdgeInsets
//                                                                           .only(
//                                                                           top:
//                                                                               2.0),
//                                                                       child:
//                                                                           Text(
//                                                                         "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
//                                                                         style:
//                                                                             const TextStyle(
//                                                                           fontSize:
//                                                                               10,
//                                                                           fontWeight:
//                                                                               FontWeight.bold,
//                                                                           color:
//                                                                               Colors.black,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                           ],
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                         ),
//                                       ],
//                                     ),
//                                     if (nameController.text.isNotEmpty)
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                               "Name: ${controller.customerName}",
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12)),
//                                           Text("Phone: ${controller.phone}",
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12)),
//                                           Text("Email: ${controller.email}",
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12)),
//                                           Text("Address: ${controller.address}",
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12)),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 10),

//                               // Bill info section
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     SizedBox(
//                                       height: 30,
//                                       width: 130,
//                                       child: AddSalesFormfield(
//                                         labelText: "Bill No",
//                                         controller: billController,
//                                         readOnly: true,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 30,
//                                       width: 130,
//                                       child: InkWell(
//                                         onTap: () =>
//                                             controller.pickDate(context),
//                                         child: InputDecorator(
//                                           decoration: InputDecoration(
//                                             isDense: true,
//                                             suffixIcon: Icon(
//                                               Icons.calendar_today,
//                                               size: 16,
//                                               color: Theme.of(context)
//                                                   .primaryColor,
//                                             ),
//                                             suffixIconConstraints:
//                                                 const BoxConstraints(
//                                               minWidth: 16,
//                                               minHeight: 16,
//                                             ),
//                                             hintText: "Bill Date",
//                                             hintStyle: TextStyle(
//                                               color: Colors.grey.shade400,
//                                               fontSize: 9,
//                                             ),
//                                             enabledBorder: UnderlineInputBorder(
//                                               borderSide: BorderSide(
//                                                   color: Colors.grey.shade400,
//                                                   width: 0.5),
//                                             ),
//                                             focusedBorder:
//                                                 const UnderlineInputBorder(
//                                               borderSide: BorderSide(
//                                                   color: Colors.green),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             controller.formattedDate.isNotEmpty
//                                                 ? controller.formattedDate
//                                                 : "Select Date",
//                                             style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 8.0),
//                                       child: Consumer<PaymentVoucherProvider>(
//                                         builder: (context, provider, child) {
//                                           return SizedBox(
//                                             height: 30,
//                                             width: 130,
//                                             child: provider.isLoading
//                                                 ? const Center(
//                                                     child:
//                                                         CircularProgressIndicator())
//                                                 : CustomDropdownTwo(
//                                                     hint: '',
//                                                     items: provider
//                                                         .billPersonNames,
//                                                     width: double.infinity,
//                                                     height: 30,
//                                                     labelText: 'Bill Person',
//                                                     selectedItem:
//                                                         selectedBillPerson,
//                                                     onChanged: (value) {
//                                                       debugPrint(
//                                                           '=== Bill Person Selected: $value ===');
//                                                       setState(() {
//                                                         selectedBillPerson =
//                                                             value;
//                                                         selectedBillPersonData =
//                                                             provider.billPersons
//                                                                 .firstWhere(
//                                                           (person) =>
//                                                               person.name ==
//                                                               value,
//                                                         );
//                                                         selectedBillPersonId =
//                                                             selectedBillPersonData!
//                                                                 .id;
//                                                       });

//                                                       debugPrint(
//                                                           'Selected Bill Person Details:');
//                                                       debugPrint(
//                                                           '- ID: ${selectedBillPersonData!.id}');
//                                                       debugPrint(
//                                                           '- Name: ${selectedBillPersonData!.name}');
//                                                       debugPrint(
//                                                           '- Phone: ${selectedBillPersonData!.phone}');
//                                                     }),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),

//                           const SizedBox(height: 10),

//                           // Add item section
//                           if ((controller.isCash &&
//                                   controller.itemsCash.isEmpty) ||
//                               (!controller.isCash &&
//                                   controller.itemsCredit.isEmpty))
//                             InkWell(
//                               onTap: () {
//                                 showSalesDialog(context, controller);
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: colorScheme.primary,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 5,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Add item & service",
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 14),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           showSalesDialog(context, controller);
//                                         },
//                                         child: const Icon(
//                                           Icons.add,
//                                           color: Colors.white,
//                                           size: 18,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),

//                           const SizedBox(height: 20),

//                           // ✅ Items list section (Cash)
//                           if (controller.isCash &&
//                               controller.itemsCash.isNotEmpty) ...[
//                             Column(
//                               children: List.generate(
//                                   controller.itemsCash.length, (index) {
//                                 final item = controller.itemsCash[index];
//                                 return Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 3),
//                                   child: InkWell(
//                                     onTap: () {
//                                       showCashItemDetailsDialog(context, item);
//                                     },
//                                     child: Container(
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xfff4f6ff),
//                                         borderRadius: BorderRadius.circular(5),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8, vertical: 4),
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                               "${index + 1}.",
//                                               style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     item.itemName!,
//                                                     style: const TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 13,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ${item.total}",
//                                                     style: const TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 12,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             InkWell(
//                                               onTap: () {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (BuildContext
//                                                       dialogContext) {
//                                                     return AlertDialog(
//                                                       title: const Text(
//                                                           "Remove Item"),
//                                                       content: const Text(
//                                                         "Are you sure you want to remove this item?",
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.black),
//                                                       ),
//                                                       actions: [
//                                                         TextButton(
//                                                           onPressed: () {
//                                                             Navigator.pop(
//                                                                 dialogContext);
//                                                           },
//                                                           child: const Text(
//                                                               "Cancel"),
//                                                         ),
//                                                         ElevatedButton(
//                                                           onPressed: () {
//                                                             controller
//                                                                 .removeCashItem(
//                                                                     index);
//                                                             Navigator.pop(
//                                                                 dialogContext);
//                                                           },
//                                                           style: ElevatedButton
//                                                               .styleFrom(
//                                                             backgroundColor:
//                                                                 colorScheme
//                                                                     .primary,
//                                                           ),
//                                                           child: const Text(
//                                                             "Remove",
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                               child: Container(
//                                                 width: 20,
//                                                 height: 20,
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade300,
//                                                       width: 1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                 ),
//                                                 child: const Icon(
//                                                   Icons.close,
//                                                   color: Colors.green,
//                                                   size: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(height: 10),
//                             // Add more items button for cash
//                             InkWell(
//                               onTap: () {
//                                 showSalesDialog(context, controller);
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: colorScheme.primary,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 5,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Add item & service",
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 14),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           showSalesDialog(context, controller);
//                                         },
//                                         child: const Icon(
//                                           Icons.add,
//                                           color: Colors.white,
//                                           size: 18,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],

//                           // ✅ Items list section (Credit)
//                           if (!controller.isCash &&
//                               controller.itemsCredit.isNotEmpty) ...[
//                             Column(
//                               children: List.generate(
//                                   controller.itemsCredit.length, (index) {
//                                 final item = controller.itemsCredit[index];
//                                 return Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 3),
//                                   child: InkWell(
//                                     onTap: () {
//                                       showSalesDialog(context, controller);
//                                     },
//                                     child: Container(
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xfff4f6ff),
//                                         borderRadius: BorderRadius.circular(5),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8, vertical: 4),
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                               "${index + 1}. ",
//                                               style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     item.itemName!,
//                                                     style: const TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 13,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ${item.total}",
//                                                     style: const TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 12,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             InkWell(
//                                               onTap: () {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (BuildContext
//                                                       dialogContext) {
//                                                     return AlertDialog(
//                                                       title: const Text(
//                                                           "Remove Item"),
//                                                       content: const Text(
//                                                         "Are you sure you want to remove this item?",
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.black),
//                                                       ),
//                                                       actions: [
//                                                         TextButton(
//                                                           onPressed: () {
//                                                             Navigator.pop(
//                                                                 dialogContext);
//                                                           },
//                                                           child: const Text(
//                                                               "Cancel"),
//                                                         ),
//                                                         ElevatedButton(
//                                                           onPressed: () {
//                                                             controller
//                                                                 .removeCreditItem(
//                                                                     index);
//                                                             Navigator.pop(
//                                                                 dialogContext);
//                                                           },
//                                                           style: ElevatedButton
//                                                               .styleFrom(
//                                                             backgroundColor:
//                                                                 colorScheme
//                                                                     .primary,
//                                                           ),
//                                                           child: const Text(
//                                                             "Remove",
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                               child: Container(
//                                                 width: 20,
//                                                 height: 20,
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade300,
//                                                       width: 1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                 ),
//                                                 child: const Icon(
//                                                   Icons.close,
//                                                   color: Colors.green,
//                                                   size: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(height: 10),
//                             // Add more items button for credit
//                             InkWell(
//                               onTap: () {
//                                 showSalesDialog(context, controller);
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: colorScheme.primary,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 5,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Add items & service",
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 14),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           showSalesDialog(context, controller);
//                                         },
//                                         child: const Icon(
//                                           Icons.add,
//                                           color: Colors.white,
//                                           size: 18,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],

//                           // Note section
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.note_add_outlined,
//                                   color: Colors.blueAccent,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     showNoteField = !showNoteField;
//                                   });
//                                 },
//                               ),
//                               if (showNoteField)
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(right: 8.0),
//                                     child: Container(
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         border: Border.all(
//                                             color: Colors.grey.shade400,
//                                             width: 1),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 8),
//                                       child: Center(
//                                         child: TextField(
//                                           controller:
//                                               controller.saleNoteController,
//                                           style: const TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 12,
//                                           ),
//                                           maxLines: 2,
//                                           cursorHeight: 12,
//                                           decoration: InputDecoration(
//                                             isDense: true,
//                                             border: InputBorder.none,
//                                             hintText: "Note",
//                                             hintStyle: TextStyle(
//                                               color: Colors.grey.shade400,
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),

//                           // Field portion - amount, discount, tax vat, adjust total, received
//                           const FieldPortion(),

//                           // Add some bottom padding for scroll
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // ✅ Fixed bottom portion - stays at bottom
//                   BottomPortion(
//                     invoiceItems: invoiceItems,
//                     saleType: controller.isCash ? "Cash" : "Credit",
//                     customerId: controller.isCash
//                         ? "Cash"
//                         : selectedCustomerId ?? "Cash",
//                   ),
//                 ],
//               ),
//             ),
          
          
//           ),
//         ),
//       ),
//     );
//   }
// }
