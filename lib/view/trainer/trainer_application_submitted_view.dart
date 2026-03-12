import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:get/get.dart';

class TrainerApplicationSubmittedView extends StatelessWidget {
  const TrainerApplicationSubmittedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: SvgPicture.asset(
                  'assets/images/new_logo.svg',
                  height: 120,
                  color: AppColors.primary,
                ),
              ),

              const Spacer(),

              // Success Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.3),
                ),
                child: Center(
                  child: Container(
                    height: 76,
                    width: 76,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    child: const Icon(Icons.check, size: 42, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              CommonText(
                AppStrings.applicationSubmitted,
                fontSize: AppTextSizes.size22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              const CommonText(
                AppStrings.yourApplicationIsUnderReview,
                fontSize: AppTextSizes.size16,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Info Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.infoBoxBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                ),
                child: const CommonText(
                  AppStrings.onceYourApplicationHasBeenVerifiedByTheAdministratorYouMayLogInToYourAccount,
                  fontSize: AppTextSizes.size14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 3),

              const CommonText(
                AppStrings.typicalReviewTime,
                fontSize: AppTextSizes.size14,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              CommonButton(
                text: AppStrings.backToLogin,
                onPressed: () {
                  final authController = Get.find<AuthController>();
                  authController.logout();
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
