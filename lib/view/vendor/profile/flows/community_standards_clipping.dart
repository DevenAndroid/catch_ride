import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_clipping.dart';

class CommunityStandardsClippingScreen extends StatefulWidget {
  const CommunityStandardsClippingScreen({super.key});

  @override
  State<CommunityStandardsClippingScreen> createState() =>
      _CommunityStandardsClippingScreenState();
}

class _CommunityStandardsClippingScreenState
    extends State<CommunityStandardsClippingScreen> {
  bool _ackPunctuality = false;
  bool _ackProfessionalism = false;
  bool _ackSafety = false;
  bool _ackCommunication = false;

  bool get _acceptedAll =>
      _ackPunctuality && _ackProfessionalism && _ackSafety && _ackCommunication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Standards'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Force them to read/accept
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
                    'Welcome to Catch Ride, Clipper.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey200,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Standards Header
            _sectionHeader('Catch Ride Community Standards', 'Clipper Edition'),
            const SizedBox(height: 24),

            // The Standards Checks
            _standardBlock(
              title: '1. Professional Quality & Equipment Readiness',
              body:
                  'I commit to arriving with fully maintained, cleaned, and sharpened equipment to ensure the highest quality results, while delivering precise clips according to the clients requests.',
              value: _ackPunctuality,
              onChanged: (v) => setState(() => _ackPunctuality = v ?? false),
            ),
            _standardBlock(
              title: '2. Safe & Patient Handling',
              body:
                  'I understand clipping requires immense patience and an understanding of equine behavior. I commit to safe, non-abusive handling practices at all times.',
              value: _ackProfessionalism,
              onChanged: (v) =>
                  setState(() => _ackProfessionalism = v ?? false),
            ),
            _standardBlock(
              title: '3. Reliability & Punctuality',
              body:
                  'Clients depend on my schedule to manage their show operations. I commit to arriving on time and communicating any delays well in advance.',
              value: _ackSafety,
              onChanged: (v) => setState(() => _ackSafety = v ?? false),
            ),
            _standardBlock(
              title: '4. Respectful Communication',
              body:
                  'I commit to clear, professional, and respectful communication with all trainers, barn managers, and staff before, during, and after my booking.',
              value: _ackCommunication,
              onChanged: (v) => setState(() => _ackCommunication = v ?? false),
            ),

            const SizedBox(height: 32),

            // Progress indicator
            _acceptProgress(),
            const SizedBox(height: 24),

            // Accept Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _acceptedAll
                    ? () {
                        Get.off(
                          () => const ProfileSetupClippingScreen(),
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
    if (_ackPunctuality) count++;
    if (_ackProfessionalism) count++;
    if (_ackSafety) count++;
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
