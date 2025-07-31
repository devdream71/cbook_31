import 'package:cbook_dt/common/custom_round_button.dart';
import 'package:cbook_dt/feature/authentication/presentation/comapny_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/cutom_text_field.dart';

class SetNewPassword extends StatelessWidget {
  const SetNewPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextEditingController paswordController = TextEditingController();
    TextEditingController reaswordController = TextEditingController();

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          'Set New Password',
          style: TextStyle(
            color: colorScheme.primary,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animation/password.json',
                  height: 200,
                ),
                Text(
                  "Your new password must be different  ",
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "From previously used password",
                  style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.5)),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CustomTextField(
                      colorScheme: colorScheme,
                      hint: "New Password",
                      controller: paswordController,
                    )),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CustomTextField(
                      colorScheme: colorScheme,
                      hint: "Re-type Password",
                      controller: reaswordController,
                    )),
                
                const Spacer(),
                      
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomRoundButton(
                      onPressed: () {
                        if (paswordController.text.trim().isEmpty ||
                            reaswordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 1),
                            content: Text(
                              'Please, enter password and repassword.',
                              style: GoogleFonts.notoSansPhagsPa(
                                  color: Colors.white),
                            ),
                          ));
                        } else if (paswordController.text != reaswordController.text ){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 1),
                            content: Text(
                              'Password not matched. Please enter password and repassword same.',
                              style: GoogleFonts.notoSansPhagsPa(
                                  color: Colors.white),
                            ),
                          ));
                        } 
                        
                        else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ComapnyLogin()),
                            (route) => false,
                          );
                        }
                      },
                      label: "Submit"),
                ),
                      
                 const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
