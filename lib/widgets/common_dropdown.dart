import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

class CommonDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<Map<String, dynamic>> options;
  final Function(Map<String, dynamic>) onSelected;
  final String? Function(String?)? validator;

  const CommonDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: (value == null || value!.isEmpty) ? null : value,
      hint: CommonText(hint, color: AppColors.textSecondary, fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt['name'],
          child: CommonText(opt['name'] ?? '', fontSize: 14),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          final selected = options.firstWhere((opt) => opt['name'] == val);
          onSelected(selected);
        }
      },
      validator: validator,
    );
  }
}
