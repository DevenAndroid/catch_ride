import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCompletedView extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? destinationWidget;
  final String buttonText;

  const ProfileCompletedView({
    super.key,
    this.title = 'Profile Completed',
    required this.subtitle,
    this.destinationWidget,
    this.buttonText = 'Home',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              // Success Icon
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.2),
                ),
                child: Center(
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    child: const Icon(
                      Icons.check, size: 48, color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              CommonText(
                title,
                fontSize: AppTextSizes.size24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              CommonText(
                subtitle,
                fontSize: AppTextSizes.size16,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              CommonButton(
                text: buttonText,
                onPressed: () {
                  if (destinationWidget != null) {
                    Get.offAll(() => destinationWidget!);
                  } else {
                    Get.offAll(() => const GroomBottomNav());
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
