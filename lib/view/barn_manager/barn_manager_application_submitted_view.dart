import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class BarnManagerApplicationSubmittedView extends StatefulWidget {
  const BarnManagerApplicationSubmittedView({super.key});

  @override
  State<BarnManagerApplicationSubmittedView> createState() =>
      _BarnManagerApplicationSubmittedViewState();
}

class _BarnManagerApplicationSubmittedViewState
    extends State<BarnManagerApplicationSubmittedView> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    String name = _authController.currentUser.value?.firstName ?? 'there';
    if (name.isEmpty) name = 'there';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Success Icon with halo (Maroon Theme - Exactly like mockup)
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.2), // Light outer halo
                  ),
                  child: Center(
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary, // Main Maroon circle
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Welcome Text
              CommonText(
                'Welcome ${name}!',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Success Subtitle
              const CommonText(
                'Your profile has been successfully set up.',
                fontSize: 16,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Info Box (Matching Mockup exactly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.infoBoxBg, 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                child: const CommonText(
                  'You can now start exploring services and managing your bookings.',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 4),

              CommonButton(
                text: 'Back to Login',
                onPressed: () => _authController.logout(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

