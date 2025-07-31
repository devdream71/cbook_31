import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';

class PurchaseSetting extends StatelessWidget {
  const PurchaseSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Purchase Settings",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: const Column(
        children: [
          Text(
            "dfsdfj",
            style: TextStyle(color: Colors.black),
          )
        ],
      ),
    );
  }
}
