import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/application/vendor_waiting_screen.dart';

class VendorApplicationSubmitScreen extends StatefulWidget {
  const VendorApplicationSubmitScreen({super.key});

  @override
  State<VendorApplicationSubmitScreen> createState() =>
      _VendorApplicationSubmitScreenState();
}

class _VendorApplicationSubmitScreenState
    extends State<VendorApplicationSubmitScreen> {
  bool _agreedToTerms = false;
  bool _agreedCommunity = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Submit'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepNavy,
                    AppColors.deepNavy.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    color: AppColors.mutedGold,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Almost There!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review the agreements below to complete your application.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Community Expectations Section
            Text(
              'Community Expectations',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 12),
            _buildExpectationItem(
              Icons.verified_user,
              'Professionalism',
              'Maintain a high standard of service and communication.',
            ),
            _buildExpectationItem(
              Icons.schedule,
              'Punctuality',
              'Arrive on time for all booked appointments.',
            ),
            _buildExpectationItem(
              Icons.favorite,
              'Animal Welfare',
              'Prioritize the safety and comfort of all horses.',
            ),
            _buildExpectationItem(
              Icons.star,
              'Quality Service',
              'Deliver consistent, quality work that matches your listing.',
            ),
            _buildExpectationItem(
              Icons.chat,
              'Communication',
              'Respond to inquiries and booking requests promptly.',
            ),
            const SizedBox(height: 24),

            // Terms Agreement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _agreedCommunity,
                    onChanged: (val) {
                      setState(() => _agreedCommunity = val ?? false);
                    },
                    title: Text(
                      'I agree to uphold the Community Expectations',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    activeColor: AppColors.deepNavy,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() => _agreedToTerms = val ?? false);
                    },
                    title: Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    activeColor: AppColors.deepNavy,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Submit Application',
              onPressed: (_agreedToTerms && _agreedCommunity)
                  ? () {
                      Get.offAll(() => const VendorWaitingScreen());
                    }
                  : () {
                      Get.snackbar(
                        'Required',
                        'Please agree to both terms to continue',
                        backgroundColor: AppColors.softRed,
                        colorText: Colors.white,
                      );
                    },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectationItem(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mutedGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.mutedGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
