// part of 'sales_view.dart';

// class AddSales extends StatelessWidget {
//   const AddSales({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final controller = context.watch<SalesController>();

//     return Container(
//       // width: double.infinity,
//       height: 350,
//       decoration: BoxDecoration(
//         color: const Color(0xffe7edf4),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Icon(
//                       Icons.cancel,
//                       size: 15,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),

//                 // Category and Subcategory Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Category Dropdown
//                     Expanded(
//                       flex: 4,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Category",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black),
//                             ),
//                             height: 30,
//                             width: double.infinity,
//                             child: DropdownButton<String>(
//                               isDense: true,
//                               value: controller.selectedCategory,
//                               icon: const Icon(Icons.arrow_drop_down),
//                               isExpanded: true,
//                               onChanged: (String? newValue) {
//                                 controller.updateCategory(newValue);
//                               },
//                               items: controller.category.map((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 3.0),
//                                     child: Text(value,
//                                         style: TextStyle(
//                                             color: Colors.black, fontSize: 14)),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),

//                     // Subcategory Dropdown
//                     Expanded(
//                       flex: 4,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Sub Category",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black),
//                             ),
//                             height: 30,
//                             width: double.infinity,
//                             child: DropdownButton<String>(
//                               isDense: true,
//                               value: controller.selectedSubCategory,
//                               icon: const Icon(Icons.arrow_drop_down),
//                               isExpanded: true,
//                               onChanged: (String? newValue) {
//                                 controller.updateSubCategory(newValue);
//                               },
//                               items: controller.subCategory.map((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 3.0),
//                                     child: Text(value,
//                                         style: TextStyle(
//                                             color: Colors.black, fontSize: 14)),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "item Name",
//                       style: TextStyle(color: Colors.black, fontSize: 14),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black),
//                       ),
//                       height: 30,
//                       width: double.infinity,
//                       child: DropdownButton<String>(
//                         isDense: true,
//                         value: controller.seletedItemName,
//                         icon: const Icon(Icons.arrow_drop_down),
//                         isExpanded: true,
//                         onChanged: (String? newValue) {
//                           controller.updateItemName(newValue);
//                         },
//                         items: controller.itemName.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 3.0),
//                               child: Text(value,
//                                   style: TextStyle(
//                                       color: Colors.black, fontSize: 14)),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Code",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: double.infinity,
//                             child: TextField(
//                               controller: TextEditingController(),
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 1),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 1),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "MRP",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: double.infinity,
//                             child: TextField(
//                               controller: TextEditingController(),
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 0.5),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 0.5),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Qty",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: double.infinity,
//                             child: TextField(
//                               controller: TextEditingController(),
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 1),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 1),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Unit",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: double.infinity,
//                             child: TextField(
//                               controller: TextEditingController(),
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 0.5),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 0.5),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Price",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: double.infinity,
//                             child: TextField(
//                               controller: TextEditingController(),
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 1),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 1),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Amount",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: double.infinity,
//                             child: TextField(
//                               controller: TextEditingController(),
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 0.5),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(0),
//                                   borderSide: const BorderSide(
//                                       color: Colors.black, width: 0.5),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Spacer(),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: InkWell(
//                 onTap: () {
//                   debugPrint("Add Item");

//                       final salesController = Provider.of<SalesController>(context, listen: false);
//                   controller.addItem();
//                   debugPrint(controller.items.length.toString());
//                   Navigator.pop(context); 
//                 },
//                 child: DecoratedBox(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.black87,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 6.0, vertical: 2),
//                       child: Text(
//                         "Ok",
//                         style: TextStyle(color: Colors.white, fontSize: 14),
//                       ),
//                     )),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
