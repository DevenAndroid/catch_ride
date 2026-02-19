
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/trainer/trainer_main_screen.dart'; // Or wherever next flow is

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, size: 64, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 32),
              Text(
                'Stay Updated',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.deepNavy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enable notifications to never miss booking updates, new messages, or review alerts.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                text: 'Enable Notifications',
                onPressed: () {
                  // Request permission logic here
                  Get.offAll(() => const TrainerMainScreen()); // Proceed to app
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.offAll(() => const TrainerMainScreen());
                },
                child: Text('Maybe Later', style: AppTextStyles.labelLarge.copyWith(color: AppColors.grey500)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
