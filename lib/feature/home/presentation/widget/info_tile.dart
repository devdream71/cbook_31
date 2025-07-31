// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class InfoTile extends StatelessWidget {
//   final Color iconColor;
//   final String label;
//   final String value;

//   const InfoTile({
//     super.key,
//     required this.iconColor,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.circle,
//                 color: iconColor,
//                 size: 10,
//               ),
//               const SizedBox(width: 5),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.black.withOpacity(0.5),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: GoogleFonts.lato(
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
