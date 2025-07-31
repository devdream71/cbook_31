// import 'package:flutter/material.dart';

// import '../../../common/input_field.dart';

// class GiveInformation extends StatelessWidget {
//   const GiveInformation({super.key});

//   @override
//   Widget build(BuildContext context) {

//     TextEditingController nameController = TextEditingController();
//     TextEditingController phone = TextEditingController();
//     TextEditingController email = TextEditingController();
//     TextEditingController address = TextEditingController();

//     final colorScheme = Theme.of(context).colorScheme;
//     return Container(
//         width: 300,
//         height: 300,
//         decoration: BoxDecoration(
//             color: const Color(0xffe7edf4),
//             borderRadius: BorderRadius.circular(5)),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Icon(
//                     Icons.cancel,
//                     size: 15,
//                   ),
//                 ),
//               ),
//               DecoratedBox(
//                 decoration: BoxDecoration(
//                     color: const Color(0xff38b0e3),
//                     borderRadius: BorderRadius.circular(20)),
//                 child: const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
//                   child: Text(
//                     "Give Information",
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: Column(
//                   children: [
//                      CustomTextField(
//                       controller: nameController,
//                       height: 30,
//                       hintText: "Customer Name",
//                       textStyle: TextStyle(color: Colors.black, fontSize: 12),
//                     ),
//                      CustomTextField(
//                       controller: phone,
//                       height: 30,
//                       hintText: "Mobile/Phone Number",
//                       textStyle: TextStyle(color: Colors.black, fontSize: 12),
//                     ),
//                      CustomTextField(
//                       controller: email,
//                       height: 30,
//                       hintText: "E-mail",
//                       textStyle: TextStyle(color: Colors.black, fontSize: 12),
//                     ),
//                     Container(
                      
//                       height: 80,
//                       decoration: BoxDecoration(
//                           border:
//                               Border.all(color: colorScheme.primary, width: 1),
//                           borderRadius: BorderRadius.circular(5)),
//                       child: TextField(
//                         controller: address,
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 12),
//                         cursorHeight: 12,
//                         decoration: InputDecoration(
//                             isDense: true,
//                             contentPadding:
//                                 const EdgeInsets.only(bottom: 5, left: 5),
//                             hintText: "Address",
//                             hintStyle: TextStyle(
//                               color: Colors.grey.shade400,
//                               fontSize: 12,
//                             ),
//                             enabledBorder: InputBorder.none,
//                             focusedBorder: InputBorder.none),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                           child: DecoratedBox(
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: Colors.black.withOpacity(0.3))),
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 2.0, horizontal: 4),
//                               child: Text(
//                                 "Cancel",
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         InkWell(
//                           onTap: (){

//                           },
//                           child: DecoratedBox(
//                             decoration: BoxDecoration(color: colorScheme.primary),
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 2.0, horizontal: 4),
//                               child: Text(
//                                 "OK",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
// }
