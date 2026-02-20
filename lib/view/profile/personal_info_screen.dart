import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Personal Information Screen',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
        ),
      ),
    );
  }
}
