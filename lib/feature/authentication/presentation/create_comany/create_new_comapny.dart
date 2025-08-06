import 'package:cbook_dt/common/cutom_text_field.dart';
import 'package:cbook_dt/feature/authentication/presentation/create_comany/otp_screen_new_company.dart';
import 'package:cbook_dt/feature/authentication/provider/reg_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateNewCompany extends StatefulWidget {
  const CreateNewCompany({super.key});

  @override
  CreateNewCompanyState createState() => CreateNewCompanyState();
}

class CreateNewCompanyState extends State<CreateNewCompany> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _selectedCountryId;

  @override
  void initState() {
    super.initState();

    _countryCodeController.text = ""; // default to Bangladesh or blank

    Future.microtask(() {
      Provider.of<AuthService>(context, listen: false).fetchCountries();
    });
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() {});

    //////====> this code was working with out validtion.
    // final registerResponse = await authService.registerUser(
    //   name: _nameController.text.trim(),
    //   email: _emailController.text.trim(),
    //   phone: _phoneController.text.trim(),
    //   countryId: int.tryParse(_selectedCountryId ?? "0") ?? 0,
    //   password: _passwordController.text.trim(),
    //   confirmPassword: _confirmPasswordController.text.trim(),
    // );

    // if (registerResponse != null && registerResponse.success) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(registerResponse.message)),
    //   );

    //   if (registerResponse.data?.token != null &&
    //       registerResponse.data!.token!.isNotEmpty) {
    //         debugPrint(" user id  =====> ${registerResponse.data!.id}");
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (_) => OtpScreenNewCompany(id:  registerResponse.data!.id, email: _emailController.text)),
    //     );
    //   }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content: Text(registerResponse?.message ?? "Something went wrong")),
    //   );
    // }

    final registerResponse = await authService.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      countryId: int.tryParse(_selectedCountryId ?? "0") ?? 0,
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (registerResponse != null && registerResponse.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(registerResponse.message)),
      );

      if (registerResponse.data?.token != null &&
          registerResponse.data!.token!.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreenNewCompany(
              id: registerResponse.data!.id,
              email: _emailController.text,
            ),
          ),
        );
      }
    } else {
      // 🛠 Show error message from AuthService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(authService.errorMessage ?? "Something went wrong"),
        ),
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _countryController.clear();
    _countryCodeController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final authService = Provider.of<AuthService>(context);
    final countries = authService.countries;

    return Scaffold(
      //backgroundColor: colorScheme.secondary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                    color: colorScheme.primary,
                  ),
                  Text(
                    "Create Company",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///company name header
                    _buildFieldLabel("Company Name", textTheme, colorScheme),
                    const SizedBox(height: 8),

                    ///company name
                    CustomTextField(
                      hint: "Enter your company name",
                      colorScheme: colorScheme,
                      controller: _nameController,
                      validator: (value) =>
                          value!.isEmpty ? "Company name is required" : null,
                    ),
                    const SizedBox(height: 20),

                    ///email
                    _buildFieldLabel("Email", textTheme, colorScheme),
                    const SizedBox(height: 8),

                    CustomTextField(
                      hint: "Enter your email",
                      colorScheme: colorScheme,
                      controller: _emailController,
                      validator: (value) => value!.isEmpty
                          ? "Email is required"
                          : (!value.contains("@")
                              ? "Enter a valid email"
                              : null),
                    ),

                    const SizedBox(height: 20),

                    _buildFieldLabel("Country", textTheme, colorScheme),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: "Select your country",
                      ),
                      value: _selectedCountryId,
                      items: countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country.id.toString(),
                          child: Text(country.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final selected = countries.firstWhere(
                          (country) => country.id.toString() == value,
                          orElse: () => countries.first,
                        );

                        setState(() {
                          _selectedCountryId = value;
                          _countryController.text = value!;
                          _countryCodeController.text =
                              selected.code; // ✅ update text controller
                        });

                        debugPrint('country id - $_selectedCountryId');
                      },
                      validator: (value) =>
                          value == null ? "Please select a country" : null,
                    ),

                    const SizedBox(height: 20),
                    _buildFieldLabel("Phone", textTheme, colorScheme),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _countryCodeController,
                            enabled: false,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: CustomTextField(
                            hint: "Enter your phone number",
                            colorScheme: colorScheme,
                            controller: _phoneController,
                            validator: (value) => value!.isEmpty
                                ? "Phone number is required"
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildFieldLabel("Password", textTheme, colorScheme),

                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: "Enter your password",
                      colorScheme: colorScheme,
                      controller: _passwordController,
                      isObscure: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel(
                        "Confirm Password", textTheme, colorScheme),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: "Confirm your password",
                      colorScheme: colorScheme,
                      controller: _confirmPasswordController,
                      isObscure: true, // ✅ Use isObscure instead of isPassword
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm Password is required";
                        }
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            authService.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: authService.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Register",
                                style: TextStyle(color: Colors.white),
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

  Padding _buildFieldLabel(
      String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
