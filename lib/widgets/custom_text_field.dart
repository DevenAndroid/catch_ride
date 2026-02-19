
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final TextEditingController? controller;
  final String? errorText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.controller,
    this.errorText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge,
          maxLines: isPassword ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
