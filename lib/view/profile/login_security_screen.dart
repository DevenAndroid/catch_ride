import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class LoginSecurityScreen extends StatelessWidget {
  const LoginSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login & Security'), centerTitle: true),
      body: Center(
        child: Text(
          'Login & Security Screen',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
        ),
      ),
    );
  }
}
