import 'package:cbook_dt/common/otp_field.dart';
import 'package:cbook_dt/feature/authentication/presentation/create_comany/roll_page.dart';
import 'package:cbook_dt/feature/authentication/provider/otp_provider.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class OtpScreenNewCompany extends StatefulWidget {
  final int id;
  final String email;
  const OtpScreenNewCompany({super.key, required this.id, required this.email});

  @override
  OtpScreenNewCompanyState createState() => OtpScreenNewCompanyState();
}

class OtpScreenNewCompanyState extends State<OtpScreenNewCompany> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  bool _isSubmitting = false;

  void _verifyOtp() async {
    // Collect OTP values from the controllers
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = Provider.of<VerificationProvider>(context, listen: false);
    await provider.verifyOtp(widget.id, otp);
    setState(() => _isSubmitting = false);

    if (provider.errorMessage?.isNotEmpty ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification successful!")),
      );
      // Navigate to next screen if needed
      final userData = provider.response?.data;
      if (userData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserRoll(
              name: userData.name,
              data: userData.createdAt,
              roll: userData.userType,
              email: userData.email,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.secondary,
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
                  const Spacer(),
                ],
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/animation/otp.json', height: 200),
                    vPad10,
                    Text(
                      widget.email,
                      style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          fontSize: 14),
                    ),
                    vPad10,
                    Text(
                      "Enter the 6-digit OTP sent to your email.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface, fontSize: 12),
                    ),
                    const SizedBox(height: 50),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: 35,
                            child: OtpField(
                              controller: _otpControllers[index],
                              index: index,
                              colorScheme: colorScheme,
                              onChanged: (value, node) {
                                if (value.isNotEmpty) {
                                  // Move to the next field
                                  if (index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                } else if (index > 0) {
                                  // Move to the previous field when erasing input
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Submit",
                                style: textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
