import 'package:flutter/material.dart';


class CompanySettings extends StatelessWidget {
  const CompanySettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,

        title: const Text(
          'Company Settings',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
    color: Colors.white, // ← makes back icon white
  ),
        automaticallyImplyLeading: true,
        
      ),
      body: const Text("cBook"),
    );
  }
}

 
