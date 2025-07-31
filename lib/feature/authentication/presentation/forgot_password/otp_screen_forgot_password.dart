import 'package:cbook_dt/feature/authentication/presentation/forgot_password/set_new_password.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/otp_field.dart';

class OtpScreenForgotPassword extends StatelessWidget {
  const OtpScreenForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    TextEditingController otpController = TextEditingController();

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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

                  // To balance alignment
                ],
              ),

              Lottie.asset(
                'assets/animation/otp.json',
                height: 150,
              ),

              vPad20,

              // Email Verification Text
              Text(
                "dreamtexh23@mail",
                style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Instructions
              Text(
                "Send 4-digit OTP to your mail from Commerce Book.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface, fontSize: 14),
              ),

              const SizedBox(height: 50),

              // OTP Fields with Padding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 50,
                      child: OtpField(
                        controller: otpController,
                        index: index,
                        colorScheme: colorScheme,
                        onChanged: (value, node) {
                          if (value.isNotEmpty) {
                            FocusScope.of(context).nextFocus();
                          } else if (index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),

             
              const Spacer(),

              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (otpController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 1),
                          content: Text(
                            'Please, enter OTP.',
                            style: GoogleFonts.notoSansPhagsPa(   
                                color: Colors.white),
                          ),
                        ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SetNewPassword()));

                              
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
