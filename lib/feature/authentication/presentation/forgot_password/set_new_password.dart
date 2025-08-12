import 'package:cbook_dt/common/custom_round_button.dart';
import 'package:cbook_dt/feature/authentication/presentation/comapny_login.dart';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/provider/forget_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../common/cutom_text_field.dart';

class SetNewPassword extends StatelessWidget {
    final int userId;
  final String email;

  const SetNewPassword({super.key, required this.userId,
    required this.email,});

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
        title: Text('Set New Password', style: TextStyle(color: colorScheme.primary)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/animation/password.json', height: 200),
              const SizedBox(height: 30),
              CustomTextField(
                colorScheme: colorScheme,
                hint: "New Password",
                controller: passwordController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                colorScheme: colorScheme,
                hint: "Re-type Password",
                controller: rePasswordController,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomRoundButton(
                  onPressed: () async {
                    final pass = passwordController.text.trim();
                    final confirm = rePasswordController.text.trim();

                    if (pass.isEmpty || confirm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please enter password and confirm password')),
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

                    final provider = Provider.of<ForgotPasswordProvider>(context, listen: false);
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   final ColorScheme colorScheme = Theme.of(context).colorScheme;
  //   TextEditingController paswordController = TextEditingController();
  //   TextEditingController reaswordController = TextEditingController();

  //   return Scaffold(
  //     backgroundColor: colorScheme.secondary,
  //     appBar: AppBar(
  //       backgroundColor: colorScheme.secondary,
  //       leading: InkWell(
  //         onTap: () {
  //           Navigator.pop(context);
  //         },
  //         child: Icon(
  //           Icons.arrow_back_ios,
  //           color: colorScheme.primary,
  //         ),
  //       ),
  //       title: Text(
  //         'Set New Password',
  //         style: TextStyle(
  //           color: colorScheme.primary,
  //         ),
  //       ),
  //     ),
  //     body: GestureDetector(
  //       onTap: () {
  //         FocusScope.of(context).unfocus();
  //       },
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Center(
  //           child: Column(
  //             // mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Lottie.asset(
  //                 'assets/animation/password.json',
  //                 height: 200,
  //               ),
  //               Text(
  //                 "Your new password must be different  ",
  //                 textAlign: TextAlign.justify,
  //                 style: GoogleFonts.roboto(
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 16,
  //                   color: Colors.black.withOpacity(0.5),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               Text(
  //                 "From previously used password",
  //                 style: GoogleFonts.roboto(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.black.withOpacity(0.5)),
  //               ),
  //               const SizedBox(
  //                 height: 30,
  //               ),
  //               SizedBox(
  //                   width: double.infinity,
  //                   height: 50,
  //                   child: CustomTextField(
  //                     colorScheme: colorScheme,
  //                     hint: "New Password",
  //                     controller: paswordController,
  //                   )),
  //               const SizedBox(height: 20),
  //               SizedBox(
  //                   width: double.infinity,
  //                   height: 50,
  //                   child: CustomTextField(
  //                     colorScheme: colorScheme,
  //                     hint: "Re-type Password",
  //                     controller: reaswordController,
  //                   )),
                
  //               const Spacer(),
                      
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 50,
  //                 child: CustomRoundButton(
  //                     onPressed: () {
  //                       if (paswordController.text.trim().isEmpty ||
  //                           reaswordController.text.trim().isEmpty) {
  //                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                           backgroundColor: Colors.red,
  //                           duration: const Duration(seconds: 1),
  //                           content: Text(
  //                             'Please, enter password and repassword.',
  //                             style: GoogleFonts.notoSansPhagsPa(
  //                                 color: Colors.white),
  //                           ),
  //                         ));
  //                       } else if (paswordController.text != reaswordController.text ){
  //                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                           backgroundColor: Colors.red,
  //                           duration: const Duration(seconds: 1),
  //                           content: Text(
  //                             'Password not matched. Please enter password and repassword same.',
  //                             style: GoogleFonts.notoSansPhagsPa(
  //                                 color: Colors.white),
  //                           ),
  //                         ));
  //                       } 
                        
  //                       else {
  //                         Navigator.pushAndRemoveUntil(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (_) => const ComapnyLogin()),
  //                           (route) => false,
  //                         );
  //                       }
  //                     },
  //                     label: "Submit"),
  //               ),
                      
  //                const SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }


