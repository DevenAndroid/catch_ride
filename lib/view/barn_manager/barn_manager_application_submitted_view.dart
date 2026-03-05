import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';

// Add Get for navigation
import 'package:get/get.dart';
import 'barn_manager_bottom_nav.dart';

class BarnManagerApplicationSubmittedView extends StatefulWidget {
  const BarnManagerApplicationSubmittedView({super.key});

  @override
  State<BarnManagerApplicationSubmittedView> createState() =>
      _BarnManagerApplicationSubmittedViewState();
}

class _BarnManagerApplicationSubmittedViewState
    extends State<BarnManagerApplicationSubmittedView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const BarnManagerBottomNav());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Icon container
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF16A34A,
                    ).withValues(alpha: 0.2), // Light green
                  ),
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF16A34A), // Dark Green
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const CommonText(
                  'Welcome John!',
                  fontSize: AppTextSizes.size22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                const CommonText(
                  'Start managing the trainer\'s account',
                  fontSize: AppTextSizes.size16,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
