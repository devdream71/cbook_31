import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({super.key});

  @override
  TransactionViewState createState() => TransactionViewState();
}

class TransactionViewState extends State<TransactionView> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.primary,
          title: const Text(
            "Transaction",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          mainAxisAlignment: MainAxisAlignment.center, 
        
        children: [
          Center(
            child: Text(
              'No Transaction',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ]),
      ),
    );
  }
}
