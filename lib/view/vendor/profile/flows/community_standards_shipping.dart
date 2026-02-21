import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_shipping.dart';

class CommunityStandardsShippingScreen extends StatefulWidget {
  const CommunityStandardsShippingScreen({super.key});

  @override
  State<CommunityStandardsShippingScreen> createState() =>
      _CommunityStandardsShippingScreenState();
}

class _CommunityStandardsShippingScreenState
    extends State<CommunityStandardsShippingScreen> {
  bool _ackSafety = false;
  bool _ackCompliance = false;
  bool _ackCare = false;
  bool _ackCommunication = false;

  bool get _acceptedAll =>
      _ackSafety && _ackCompliance && _ackCare && _ackCommunication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Standards'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Approval Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepNavy, AppColors.deepNavy],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mutedGold.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.mutedGold,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Application Approved!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to Catch Ride, Shipping Vendor.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey200,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _sectionHeader(
              'Catch Ride Community Standards',
              'Shipping Edition',
            ),
            const SizedBox(height: 24),

            _standardBlock(
              title: '1. Safety & Maintenance',
              body:
                  'I commit to maintaining my equipment to the highest safety standards and following all DOT safety regulations during every trip.',
              value: _ackSafety,
              onChanged: (v) => setState(() => _ackSafety = v ?? false),
            ),
            _standardBlock(
              title: '2. Regulatory Compliance',
              body:
                  'I will maintain all required licenses, insurance, and authority for commercial livestock transport as per federal and state laws.',
              value: _ackCompliance,
              onChanged: (v) => setState(() => _ackCompliance = v ?? false),
            ),
            _standardBlock(
              title: '3. Humane Animal Transport',
              body:
                  'The well-being of the horses is my priority. I commit to safe driving practices, regular checks, and providing water and hay as agreed.',
              value: _ackCare,
              onChanged: (v) => setState(() => _ackCare = v ?? false),
            ),
            _standardBlock(
              title: '4. Reliable Communication',
              body:
                  'I commit to providing timely updates to owners and trainers regarding pickup, transit progress, and expected delivery times.',
              value: _ackCommunication,
              onChanged: (v) => setState(() => _ackCommunication = v ?? false),
            ),

            const SizedBox(height: 32),

            _acceptProgress(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _acceptedAll
                    ? () {
                        Get.off(
                          () => const ProfileSetupShippingScreen(),
                          transition: Transition.rightToLeft,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  disabledBackgroundColor: AppColors.grey300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _acceptedAll
                      ? 'I Accept — Complete My Profile'
                      : 'Accept All Standards to Continue',
                  style: AppTextStyles.button.copyWith(
                    color: _acceptedAll ? Colors.white : AppColors.grey500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.mutedGold),
        ),
        const SizedBox(height: 12),
        Container(height: 2, width: 60, color: AppColors.mutedGold),
      ],
    );
  }

  Widget _standardBlock({
    required String title,
    required String body,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: value
            ? AppColors.successGreen.withOpacity(0.05)
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.successGreen.withOpacity(0.5)
              : AppColors.grey200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: value,
                    onChanged: onChanged,
                    activeColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _acceptProgress() {
    int count = 0;
    if (_ackSafety) count++;
    if (_ackCompliance) count++;
    if (_ackCare) count++;
    if (_ackCommunication) count++;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$count of 4 Accepted',
          style: AppTextStyles.labelLarge.copyWith(
            color: count == 4 ? AppColors.successGreen : AppColors.grey600,
            fontWeight: count == 4 ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
