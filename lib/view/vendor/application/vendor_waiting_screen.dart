import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/profile/vendor_profile_complete_screen.dart';

class VendorWaitingScreen extends StatelessWidget {
  const VendorWaitingScreen({super.key});

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

              // Animated icon area
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.mutedGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 40,
                      color: AppColors.mutedGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Application Submitted!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Our team is reviewing your application.\nYou\'ll be notified once approved.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.grey600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  children: [
                    _buildStatusRow(
                      'Application Received',
                      'Completed',
                      Icons.check_circle,
                      AppColors.successGreen,
                    ),
                    const Divider(height: 24),
                    _buildStatusRow(
                      'Under Review',
                      'In Progress',
                      Icons.access_time,
                      AppColors.mutedGold,
                    ),
                    const Divider(height: 24),
                    _buildStatusRow(
                      'Approval',
                      'Pending',
                      Icons.pending_outlined,
                      AppColors.grey400,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // For demo purposes: Skip to approved
              CustomButton(
                text: 'Continue (Demo: Approved)',
                onPressed: () {
                  Get.offAll(() => const VendorProfileCompleteScreen());
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTextStyles.bodyLarge)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
