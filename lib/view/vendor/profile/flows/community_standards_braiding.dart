import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_braiding.dart';

class CommunityStandardsBraiderScreen extends StatefulWidget {
  const CommunityStandardsBraiderScreen({super.key});

  @override
  State<CommunityStandardsBraiderScreen> createState() =>
      _CommunityStandardsBraiderScreenState();
}

class _CommunityStandardsBraiderScreenState
    extends State<CommunityStandardsBraiderScreen> {
  bool _acceptedAll = false;

  final _checks = <String, bool>{
    'punctual': false,
    'professional': false,
    'platform': false,
    'age': false,
  };

  bool get _allChecked => _checks.values.every((v) => v);

  void _onCheck(String key, bool? val) {
    setState(() {
      _checks[key] = val ?? false;
      _acceptedAll = _allChecked;
    });
  }

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
            // ── Approval Banner ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Approved 🎉',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Before you go live, please read and accept the Catch Ride community standards for Braiders.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Standards Header ──────────────────────────────────────────
            _sectionHeader('Catch Ride Community Standards', 'Braider Edition'),
            const SizedBox(height: 20),

            // ── Standard 1: Punctuality ─────────────────────────────
            _standardBlock(
              index: '01',
              title: 'Punctuality & Reliability',
              icon: Icons.timer_outlined,
              body:
                  'You agree to arrive on time for all confirmed bookings. '
                  'Shows operate on strict schedules, and late arrivals negatively impact the team. '
                  'Consistent tardiness or no-shows may result in platform removal.',
              checkKey: 'punctual',
            ),
            const SizedBox(height: 16),

            // ── Standard 2: Professionalism ───────────────────────────────
            _standardBlock(
              index: '02',
              title: 'Professional Conduct',
              icon: Icons.handshake_outlined,
              body:
                  'You agree to uphold a high standard of professionalism in the barn and at the ring. '
                  'This includes maintaining a tidy workspace and communicating respectfully with '
                  'barn managers, trainers, and other staff.',
              checkKey: 'professional',
            ),
            const SizedBox(height: 16),

            // ── Standard 3: Platform Rules ────────────────────────────────
            _standardBlock(
              index: '03',
              title: 'Platform-Only Communication (MVP)',
              icon: Icons.chat_bubble_outline_rounded,
              body:
                  'During this phase of the platform, all client communication and booking '
                  'coordination must occur through Catch Ride\'s in-app messaging system. '
                  'You agree not to solicit off-platform contact during the booking process.',
              checkKey: 'platform',
            ),
            const SizedBox(height: 16),

            // ── Standard 4: Age / Identity ────────────────────────────────
            _standardBlock(
              index: '04',
              title: 'Age & Identity Confirmation',
              icon: Icons.verified_outlined,
              body:
                  'You confirm that you are 18 years of age or older, and that all information '
                  'provided during your application is accurate and truthful. '
                  'Misrepresentation may result in immediate account suspension.',
              checkKey: 'age',
            ),
            const SizedBox(height: 32),

            // ── Progress indicator ─────────────────────────────────────────
            _acceptProgress(),
            const SizedBox(height: 24),

            // ── Accept Button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _acceptedAll
                    ? () => Get.off(
                        () => const ProfileSetupBraidingScreen(),
                        transition: Transition.rightToLeft,
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.grey200,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _acceptedAll
                      ? 'I Accept — Complete My Profile'
                      : 'Accept All Standards to Continue',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'These standards apply specifically to Braider accounts. Full text provided by admin later.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey400,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build helpers
  // ─────────────────────────────────────────────────────────────────────────

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
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 4),
        Container(height: 3, width: 48, color: AppColors.mutedGold),
      ],
    );
  }

  Widget _standardBlock({
    required String index,
    required String title,
    required IconData icon,
    required String body,
    required String checkKey,
  }) {
    final isChecked = _checks[checkKey] ?? false;
    final accentColor = AppColors.deepNavy;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isChecked
            ? AppColors.successGreen.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChecked
              ? AppColors.successGreen.withOpacity(0.4)
              : AppColors.grey200,
          width: isChecked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    index,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: accentColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isChecked)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.successGreen,
                  ),
              ],
            ),
          ),
          // Body text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              body,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey700,
                height: 1.55,
              ),
            ),
          ),
          // Checkbox row
          CheckboxListTile(
            value: isChecked,
            onChanged: (v) => _onCheck(checkKey, v),
            title: Text(
              'I have read and agree to this standard',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isChecked ? AppColors.successGreen : AppColors.grey600,
              ),
            ),
            activeColor: AppColors.successGreen,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _acceptProgress() {
    final accepted = _checks.values.where((v) => v).length;
    final total = _checks.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Standards accepted',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            Text(
              '$accepted / $total',
              style: AppTextStyles.bodySmall.copyWith(
                color: accepted == total
                    ? AppColors.successGreen
                    : AppColors.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: accepted / total,
            minHeight: 6,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation(AppColors.successGreen),
          ),
        ),
      ],
    );
  }
}
