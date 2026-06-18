import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.bottomPadding = 0.0,
    this.topPadding = 20,
    this.onFieldSubmitted, // أضفنا هذا السطر
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String hintText;
  final bool obscureText;
  final double topPadding;
  final double bottomPadding;
  final Function(String)? onFieldSubmitted; // أضفنا هذا السطر

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: FormField<String>(
        validator: validator,
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (value) {
                    field.didChange(value);
                  },
                  onSubmitted: onFieldSubmitted, // ربطنا الدالة هنا
                  textInputAction: TextInputAction
                      .search, // بيخلي الزرار في الكيبورد "Search"
                  controller: controller,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              if (field.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Text(
                    field.errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
