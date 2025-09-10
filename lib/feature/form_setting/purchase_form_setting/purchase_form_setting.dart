// import 'package:flutter/material.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class PurchaseFormSettingsPage extends StatefulWidget {
//   const PurchaseFormSettingsPage({super.key});

//   @override
//   State<PurchaseFormSettingsPage> createState() =>
//       _PurchaseFormSettingsPageState();
// }

// class _PurchaseFormSettingsPageState extends State<PurchaseFormSettingsPage> {
//   bool _isSwitchedCategory = false;
//   bool _isSwitchedPrice = false;
//   bool _isSwitchedCategoryPrice = false;
//   bool _isStataus = false;
//   bool _isSwitchedQtyPrice = false;
//   bool _isLoading = true; // NEW: Loading flag

//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isSwitchedCategory = prefs.getBool('isSwitchedCategory') ?? false;
//       _isSwitchedPrice = prefs.getBool('isSwitchedPrice') ?? false;
//       _isSwitchedCategoryPrice =
//           prefs.getBool('isSwitchedCategoryPrice') ?? false;
//       _isStataus = prefs.getBool('isStatus') ?? false;
//       _isSwitchedQtyPrice = prefs.getBool('isSwitchedQtyPrice') ?? false;
//       _isLoading = false; // Loading done
//     });
//   }

//   Future<void> _saveSettings() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isSwitchedCategory', _isSwitchedCategory);
//     prefs.setBool('isSwitchedPrice', _isSwitchedPrice);
//     prefs.setBool('isSwitchedCategoryPrice', _isSwitchedCategoryPrice);
//     prefs.setBool('isStatus', _isStataus);
//     prefs.setBool('isSwitchedQtyPrice', _isSwitchedQtyPrice);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()), // <-- Show loading
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Purchase From Settings"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Activation Switch",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             // Now your switches

//             ListTile(
//               dense: true,
//               visualDensity: VisualDensity.compact,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               title: const Text(
//                 "Enable Default Cash",
//                 style: TextStyle(fontSize: 14),
//               ),
//               trailing: Transform.scale(
//                 scale: 0.75,
//                 child: Switch(
//                   value: _isSwitchedCategory,
//                   onChanged: (bool value) {
//                     setState(() {
//                       _isSwitchedCategory = value;
//                     });
//                     _saveSettings();
//                   },
//                 ),
//               ),
//             ),

//             ListTile(
//               dense: true,
//               visualDensity: VisualDensity.compact,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               title: const Text(
//                 "Enable Categories & Sub Categories",
//                 style: TextStyle(fontSize: 14),
//               ),
//               trailing: Transform.scale(
//                 scale: 0.75,
//                 child: Switch(
//                   value: _isSwitchedPrice,
//                   onChanged: (bool value) {
//                     setState(() {
//                       _isSwitchedPrice = value;
//                     });
//                     _saveSettings();
//                   },
//                 ),
//               ),
//             ),

//             ListTile(
//               dense: true,
//               visualDensity: VisualDensity.compact,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               title: const Text(
//                 "Enable Item Base Unit & Secoundary Unit Show",
//                 style: TextStyle(fontSize: 14),
//               ),
//               trailing: Transform.scale(
//                 scale: 0.75,
//                 child: Switch(
//                   value: _isSwitchedCategoryPrice,
//                   onChanged: (bool value) {
//                     setState(() {
//                       _isSwitchedCategoryPrice = value;
//                     });
//                     _saveSettings();
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
