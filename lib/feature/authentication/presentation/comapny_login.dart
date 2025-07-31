import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custom_round_button.dart';
import 'package:cbook_dt/common/cutom_text_field.dart';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/forgot_password.dart';
import 'package:cbook_dt/feature/authentication/provider/login_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'create_comany/create_new_comapny.dart';

class ComapnyLogin extends StatelessWidget {
  const ComapnyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light, // for Android
        statusBarBrightness: Brightness.dark, // for iOS
      ),
      child: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorScheme.secondary,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Title
                      Image.asset(
                        //"assets/image/cbook_logo.png",
                        "assets/image/splash_screen_nobg.png", //assets\image\splash_screen_nobg.png
                        height: 120,
                        width: 200,
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Welcome to Commerce Book",
                        style: GoogleFonts.notoSansPhagsPa(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create New Company Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomRoundButton(
                            backgroundColor: colorScheme.primary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateNewCompany(),
                                ),
                              );

                              //showFeatureNotAvailableDialog(context);
                            },
                            label: "Create New Company"),
                      ),

                      const SizedBox(height: 20),

                      // Already Have an Account Text
                      Text(
                        "Already have your account?",
                        style: GoogleFonts.notoSansPhagsPa(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Divider(
                        height: 30,
                        color: Colors.grey.shade200,
                      ),

                      // Login Form
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email Field
                              Text(
                                "Company E-Mail",
                                style: GoogleFonts.notoSansPhagsPa(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),

                              CustomTextField(
                                  controller: emailController,
                                  hint: "",
                                  colorScheme: colorScheme),

                              

                              const SizedBox(height: 20),

                              // Password Field
                              Text(
                                "Password",
                                style: GoogleFonts.notoSansPhagsPa(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),

                              CustomTextField(
                                  isObscure: true,
                                  controller: passwordController,
                                  hint: "",
                                  colorScheme: colorScheme),

                              // AddSalesFormfield(
                              //   label: "",
                              //   controller: passwordController,
                              //   //validator: _validateRequired,
                              // ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: Consumer<LoginProvider>(
                                  builder: (context, provider, child) {
                                    return ElevatedButton(
                                      onPressed: provider.isLoading
                                          ? null
                                          : () async {
                                              if (emailController
                                                      .text.isNotEmpty &&
                                                  passwordController
                                                      .text.isNotEmpty) {
                                                // Call login method
                                                await provider.loginUser(
                                                  emailController.text,
                                                  passwordController.text,
                                                );

                                                // Only navigate to Home if login is successful
                                                if (provider.loginResponse !=
                                                        null &&
                                                    provider.loginResponse!
                                                        .success) {
                                                  emailController.clear();
                                                  passwordController.clear();

                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const HomeView(),
                                                    ),
                                                  );
                                                } else {
                                                  // Show error message if login fails
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                      provider.loginResponse
                                                              ?.message ??
                                                          'Login failed, Emial or password mismatched ',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ));
                                                }
                                              } else {
                                                // Show message if email or password is empty
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                      seconds: 1),
                                                  content: Text(
                                                    'Please, enter mail and password',
                                                    style: GoogleFonts
                                                        .notoSansPhagsPa(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ));
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: provider.isLoading
                                          ? const CircularProgressIndicator()
                                          : Text(
                                              "Login",
                                              style:
                                                  GoogleFonts.notoSansPhagsPa(
                                                color: colorScheme.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()));

                          //showFeatureNotAvailableDialog(context);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
