import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';

// Add Get for navigation
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'barn_manager_bottom_nav.dart';

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
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const BarnManagerBottomNav());
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = _authController.currentUser.value?.firstName ?? 'there';
    if (name.isEmpty) name = 'there';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Success Icon with halo
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF16A34A).withOpacity(0.2), // Halo
                  ),
                  child: Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E), // Main Green
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Welcome Text
              CommonText(
                'Welcome $name!',
                fontSize: AppTextSizes.size26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Success Subtitle
              const CommonText(
                'Your profile has been successfully set up.',
                fontSize: AppTextSizes.size16,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Info Box (as seen in mockup)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.infoBoxBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.infoBoxBorder,
                    width: 1.5,
                  ),
                ),
                child: const CommonText(
                  'You can now start exploring services and managing your bookings.',
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
