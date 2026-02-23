import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_main_screen.dart';

class BarnManagerApplicationSubmitScreen extends StatelessWidget {
  const BarnManagerApplicationSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Submitted!',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for applying to join Catch Ride as a Barn Manager. Your application details will be internally reviewed and an approval request will be sent to the associated Trainer.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.grey600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: AppColors.deepNavy,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Estimated Review Time',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Applications are reviewed manually. The associated trainer will receive an email update to approve you.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Contact Support',
                onPressed: () {
                  Get.offAll(() => const BarnManagerMainScreen());
                },
                backgroundColor: AppColors.deepNavy,
                textColor: AppColors.deepNavy,
                isOutlined: true,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Logout',
                onPressed: () {
                  Get.offAll(() => const WelcomeScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
