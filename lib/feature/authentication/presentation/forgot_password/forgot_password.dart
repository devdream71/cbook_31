import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/cutom_text_field.dart';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/provider/forget_password_provider.dart';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/set_new_password.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../common/custom_round_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Consumer<ForgotPasswordProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    // Show loading spinner over entire screen while API is in progress
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Otherwise show normal form UI
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animation/forgot_password.json',
                        height: 150,
                      ),
                      vPad15,
                      Text(
                        "Verify from cBook for forgot passowrd.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xff5156be),
                              fontSize: 13,
                            ),
                      ),
                      vPad20,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomTextField(
                          icon: Icons.email,
                          hint: "Email Address",
                          colorScheme: Theme.of(context).colorScheme,
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: CustomRoundButton(
                            label: "Next",
                            onPressed: () async {
                              final email = emailController.text.trim();
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('Please, enter an email.'),
                                  ),
                                );
                                return;
                              }

                              if (!emailRegex.hasMatch(email)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        'Please, enter a valid email address.'),
                                  ),
                                );
                                return;
                              }

                              bool success = await provider
                                  .sendForgotPasswordRequest(email);

                              if (success &&
                                  provider.responseModel?.success == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SetNewPassword(
                                      userId: provider.responseModel!.data!.id,
                                      email:
                                          provider.responseModel!.data!.email,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        'Failed to send OTP. Please try again.'),
                                  ),
                                );
                              }
                            },
                            backgroundColor: AppColors.primaryColor,
                            textStyle:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
