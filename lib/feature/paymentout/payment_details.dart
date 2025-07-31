import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {


  // Default to current date
  String? selectedDropdownValue;

 

  @override
  void initState() {
    super.initState();
    
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenseList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Column(
          children: [
            Text(
              'Payment out Deatils',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///top date start , end and dropdown
 
        
        ],
      ),
    );
  } 
  }