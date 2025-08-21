import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorTheme.primary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Report',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Report Header Section
            Center(
              child: Text(
                'Comming Soon',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
             
          ],
        ),
      ),
    );
  }
}

 