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
              const Spacer(flex: 2),

              // Success Icon with halo (Maroon Theme)
              Center(
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.3), // Halo
                  ),
                  child: Center(
                    child: Container(
                      height: 85,
                      width: 85,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary, // Main Maroon
                      ),
                      child: const Icon(
                        Icons.done_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Welcome Text
              CommonText(
                'Welcome ${name}!',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Success Subtitle
              const CommonText(
                'Your profile has been submitted for review.',
                fontSize: 16,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Info Box (Matching Mockup)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F7), // Very light pink
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: const CommonText(
                  'Your application is currently being verified by the administrator. You will be able to access all features once approved.',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5562),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 3),

              CommonButton(
                text: 'Back to Login',
                onPressed: () => _authController.logout(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

