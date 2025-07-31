import 'package:flutter/material.dart';
import 'input_field.dart';

class ReusableForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final Color primaryColor;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ReusableForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.primaryColor,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xffe7edf4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onCancel,
                child: const Icon(
                  Icons.cancel,
                  size: 15,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff38b0e3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                child: Text(
                  "Give Information",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildInputField(nameController, "Customer Name"),
            _buildInputField(phoneController, "Mobile/Phone Number"),
            _buildInputField(emailController, "E-mail"),
            _buildAddressField(addressController),
            const SizedBox(height: 5),
            _buildButtons(onCancel, onSubmit, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText) {
    return InputField(
      controller: controller,
      height: 30,
      hintText: hintText,
      textStyle: const TextStyle(color: Colors.black, fontSize: 12),
    );
  }

  Widget _buildAddressField(TextEditingController controller) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black, fontSize: 12),
        cursorHeight: 12,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.only(bottom: 5, left: 5),
          hintText: "Address",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildButtons(VoidCallback onCancel, VoidCallback onSubmit, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: onCancel,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.3)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onSubmit,
          child: DecoratedBox(
            decoration: BoxDecoration(color: primaryColor),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
