import 'dart:convert';

 
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class UserRoll extends StatelessWidget {
  final String name;
  final String data; // Date string in the format "2025-02-03T07:21:24.000000Z"
  final String roll;
  final String email;

  const UserRoll(
      {super.key,
      required this.name,
      required this.data,
      required this.roll,
      required this.email});

  Future<void> _callApi(String email, BuildContext context) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/verification/login?email=$email');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Handle the response here
        final data = json.decode(response.body);
        debugPrint("API Response: $data");

        // Show a success message or handle the data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification API call successful!")),
        );

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomeView()));
      } else {
        // Handle failure
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to verify: ${data['message']}")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Parse and format the date
    DateTime dateTime = DateTime.parse(data);
    String formattedDate = DateFormat('MMM d, yyyy, h:mm a').format(dateTime);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    "Select User Roll",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )
                ],
              ),
              Card(
                child: ListTile(
                  title: Text(
                    'Company Name: $name',
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    'Created Date: $formattedDate\nRole: $roll, \n$email',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Your onPressed action
                      _callApi(email, context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Text color
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Circular border
                      ),
                      elevation: 5, // Shadow effect
                      shadowColor: Colors.blue.withOpacity(0.4), // Shadow color
                    ),
                    child: const Text(
                      "Open",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
