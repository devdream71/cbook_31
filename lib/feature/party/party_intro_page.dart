import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AddNewPartyIntro extends StatelessWidget {
  const AddNewPartyIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    TextStyle ts = const TextStyle(color: Colors.white, fontSize: 12);
    TextStyle ts2 = const TextStyle(
        color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

    return Scaffold(
       backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Add New Party',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // ← makes back icon white
          ),
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            ///customer and supplier ,,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///Add customer
                Container(
                  decoration: const BoxDecoration(
                  
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .deepPurple, // 🔹 Set your desired background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  2), // 🔹 Border radius 2
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CustomerCreate()),
                            );
                          },
                          label: Text(
                            'New Customer',
                            style: ts,
                          ),
                          icon: const Icon(Icons.account_circle,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                ///add supplier
                Container(
                  decoration: const BoxDecoration(
                      //border: Border.all(color: Colors.green),
                      //borderRadius: BorderRadius.circular(6)
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .deepPurple, // 🔹 Set your desired background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  2), // 🔹 Border radius 2
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SuppliersCreate()),
                            );
                          },
                          label: Text(
                            'New Supplier',
                            style: ts,
                          ),
                          icon: const Icon(
                            Icons.group,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Lottie.asset('assets/animation/party.json', height: 400),

            const SizedBox(
              height: 10,
            ),

            Text(
              '''• Click For Customer Or Supplier
• Price Level Only For Customer''',
              style: ts2,
            ),
          ],
        ));
  }
}
