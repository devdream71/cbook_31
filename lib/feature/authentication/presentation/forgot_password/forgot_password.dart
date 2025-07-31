import 'package:cbook_dt/common/cutom_text_field.dart';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/otp_screen_forgot_password.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/custom_round_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
          'Forgot Password',
          style: TextStyle(
            color: colorScheme.primary,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animation/forgot_password.json',
                  height: 150,
                ),
                vPad15,
                Text(
                  "Verify from cBook for forgot passowrd.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                vPad20,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hint: "Email Address",
                    colorScheme: colorScheme,
                    controller: emailController,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CustomRoundButton(
                      label: "Send Otp",
                      onPressed: () {
                        if (emailController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 1),
                            content: Text(
                              'Please, enter mail.',
                              style: GoogleFonts.notoSansPhagsPa(
                                  color: Colors.white),
                            ),
                          ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const OtpScreenForgotPassword()));
                        }
                      },
                      backgroundColor: Colors.blue.shade400,
                      textStyle: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
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
