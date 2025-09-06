import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custom_round_button.dart';
import 'package:cbook_dt/feature/authentication/presentation/comapny_login.dart';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/provider/forget_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../common/cutom_text_field.dart';

class SetNewPassword extends StatelessWidget {
  final int userId;
  final String email;

  const SetNewPassword({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextEditingController passwordController = TextEditingController();
    TextEditingController rePasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
        ),
        title: Text('Set New Password',
            style: TextStyle(color: colorScheme.primary)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                  child: Lottie.asset('assets/animation/password.json',
                      height: 200)),
              const SizedBox(height: 30),
              Text(
                "New password",
                style: GoogleFonts.notoSansPhagsPa(
                  color: AppColors.button2Color,
                  fontSize: 13,
                ),
              ),
              CustomTextField(
                colorScheme: colorScheme,
                //hint: "New Password",
                controller: passwordController,
                icon: Icons.password,
                isObscure: true,
              ),
              const SizedBox(height: 20),
              Text(
                "Re-type Password",
                style: GoogleFonts.notoSansPhagsPa(
                  color: AppColors.button2Color,
                  fontSize: 13,
                ),
              ),
              CustomTextField(
                colorScheme: colorScheme,
                //hint: "Re-type Password",
                controller: rePasswordController,
                icon: Icons.password,
                isObscure: true,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomRoundButton(
                  backgroundColor: AppColors.primaryColor,
                  onPressed: () async {
                    final pass = passwordController.text.trim();
                    final confirm = rePasswordController.text.trim();

                    if (pass.isEmpty || confirm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                                'Please enter password and confirm password')),
                      );
                      return;
                    }
                    if (pass != confirm) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Passwords do not match')),
                      );
                      return;
                    }

                    final provider = Provider.of<ForgotPasswordProvider>(
                        context,
                        listen: false);
                    bool success = await provider.updatePassword(
                      userId: userId,
                      email: email,
                      password: pass,
                      confirmed: confirm,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Successfull, to update password')),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const ComapnyLogin()),
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Failed to update password')),
                      );
                    }
                  },
                  label: "Submit",
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
