// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ReusableBox extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color borderColor;
//   final Color backgroundColor;
//   final Color textColor;
//   final Color iconColor;

//   const ReusableBox({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.borderColor = Colors.black,
//     this.backgroundColor = Colors.white,
//     this.textColor = Colors.black,
//     this.iconColor = Colors.black,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final colorScheme = Theme.of(context).colorScheme;
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         color: const Color(0xffe3e7fa),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(
//           color: Colors.grey.shade300,
//           width: 1,
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 0,
//             offset: Offset(0, 0),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           vertical: 2.0,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   icon,
//                   color: iconColor,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 3),
//                 Text(
//                   label,
//                   maxLines: 1, // Ensures it doesn't exceed one line
//                   overflow: TextOverflow.ellipsis, // Handles overflow
//                   style: GoogleFonts.notoSansPhagsPa(
//                       // fontWeight: FontWeight.w600,
//                       color: textColor,
//                       fontSize: 11),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 3),
//             Text(
//               value,
//               style: GoogleFonts.notoSansPhagsPa(
//                 fontSize: 12,
//                 // fontWeight: FontWeight.w500,
//                 color: textColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
