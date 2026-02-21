import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_groom.dart';

class CommunityStandardsGroomScreen extends StatefulWidget {
  const CommunityStandardsGroomScreen({super.key});

  @override
  State<CommunityStandardsGroomScreen> createState() =>
      _CommunityStandardsGroomScreenState();
}

class _CommunityStandardsGroomScreenState
    extends State<CommunityStandardsGroomScreen> {
  bool _ackPunctuality = false;
  bool _ackCare = false;
  bool _ackProfessionalism = false;
  bool _ackCommunication = false;

  bool get _acceptedAll =>
      _ackPunctuality && _ackCare && _ackProfessionalism && _ackCommunication;

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
                    'Welcome to Catch Ride, Groom.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey200,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _sectionHeader('Catch Ride Community Standards', 'Groom Edition'),
            const SizedBox(height: 24),

            _standardBlock(
              title: '1. Punctuality & Reliability',
              body:
                  'Daily care and show schedules depend on my presence. I commit to being on time for all shifts and providing ample notice for any scheduling changes.',
              value: _ackPunctuality,
              onChanged: (v) => setState(() => _ackPunctuality = v ?? false),
            ),
            _standardBlock(
              title: '2. Exceptional Horse Care',
              body:
                  'I commit to the highest standards of grooming, stall upkeep, and health monitoring. I will treat every horse with patience, respect, and professional expertise.',
              value: _ackCare,
              onChanged: (v) => setState(() => _ackCare = v ?? false),
            ),
            _standardBlock(
              title: '3. Professionalism in the Barn',
              body:
                  'I understand the importance of maintaining a clean, organized, and focused environment. I commit to working collaboratively with trainers and other staff.',
              value: _ackProfessionalism,
              onChanged: (v) =>
                  setState(() => _ackProfessionalism = v ?? false),
            ),
            _standardBlock(
              title: '4. Proactive Communication',
              body:
                  'I commit to reporting any health or behavioral concerns to the trainer or barn manager immediately. I will maintain clear communication regarding my tasks and progress.',
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
                          () => const ProfileSetupGroomScreen(),
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
    if (_ackCare) count++;
    if (_ackProfessionalism) count++;
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
