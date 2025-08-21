import 'package:flutter/material.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'General Settings',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, 
        ),
        automaticallyImplyLeading: true,
      ),
      body: const Center(
        child: Text(
          'No General Settings',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
