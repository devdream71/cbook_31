// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CustomDashboardStats extends StatelessWidget {
//   final String title;
//   final String value;
//   final Color titleBackgroundColor;
//   final Color titleTextColor;
//   final Color valueBackgroundColor;
//   final Color valueTextColor;

//   const CustomDashboardStats({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.titleBackgroundColor,
//     required this.titleTextColor,
//     required this.valueBackgroundColor,
//     required this.valueTextColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           DecoratedBox(
//             decoration: BoxDecoration(color: titleBackgroundColor),
//             child: Center(
//               child: Text(
//                 title,
//                 style: GoogleFonts.notoSansPhagsPa(
//                     color: titleTextColor, fontSize: 14),
//               ),
//             ),
//           ),
//           DecoratedBox(
//             decoration: const BoxDecoration(color: Color(0xffdfe8f4)),
//             child: Center(
//               child: Text(
//                 value,
//                 style: GoogleFonts.notoSansPhagsPa(
//                     color: valueTextColor, fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
