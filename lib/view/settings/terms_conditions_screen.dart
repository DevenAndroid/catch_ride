import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Terms & Conditions Content',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
        ),
      ),
    );
  }
}
