// community_standards_bodywork.dart
// CommunityStandardsBodywork — shown once after Bodywork application is approved.
// Vendor must accept all terms before proceeding to ProfileCompleteBodywork.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_bodywork.dart';

class CommunityStandardsBodyworkScreen extends StatefulWidget {
  const CommunityStandardsBodyworkScreen({super.key});

  @override
  State<CommunityStandardsBodyworkScreen> createState() =>
      _CommunityStandardsBodyworkScreenState();
}

class _CommunityStandardsBodyworkScreenState
    extends State<CommunityStandardsBodyworkScreen> {
  bool _acceptedAll = false;

  // Each standard must be individually acknowledged
  final _checks = <String, bool>{
    'scope': false,
    'vetRef': false,
    'claims': false,
    'professional': false,
    'platform': false,
    'insurance': false,
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
                          'Before you go live, please read and accept the Catch Ride community standards for Bodywork Specialists.',
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
            _sectionHeader(
              'Catch Ride Community Standards',
              'Bodywork Specialist Edition',
            ),
            const SizedBox(height: 20),

            // ── Standard 1: Scope of Practice ─────────────────────────────
            _standardBlock(
              index: '01',
              title: 'Scope of Practice',
              icon: Icons.medical_information_outlined,
              body:
                  'All services offered through Catch Ride are supportive bodywork only. '
                  'You agree that your services do not constitute veterinary care, diagnosis, treatment, or prescription. '
                  'You will represent your services accurately to clients as supportive and complementary in nature.',
              checkKey: 'scope',
            ),
            const SizedBox(height: 16),

            // ── Standard 2: Veterinary Referral / Oversight ───────────────
            _standardBlock(
              index: '02',
              title: 'Restricted Modalities & Veterinary Oversight',
              icon: Icons.policy_outlined,
              body:
                  'For modalities marked as requiring veterinary referral or oversight '
                  '(Chiropractic, Acupuncture, Laser Therapy) — you confirm that you operate '
                  'only where legally permitted in your jurisdiction and in accordance '
                  'with applicable veterinary referral or oversight requirements. '
                  'This disclaimer will appear on your public profile.',
              checkKey: 'vetRef',
              highlight: true,
            ),
            const SizedBox(height: 16),

            // ── Standard 3: No Medical Claims ─────────────────────────────
            _standardBlock(
              index: '03',
              title: 'No Medical Claims or Guarantees',
              icon: Icons.block_outlined,
              body:
                  'You agree not to make medical claims, diagnostic statements, or treatment '
                  'guarantees in your profile bio, service descriptions, or client communications '
                  'on this platform. Language must emphasize supportive care, not medical outcomes.',
              checkKey: 'claims',
            ),
            const SizedBox(height: 16),

            // ── Standard 4: Professionalism ───────────────────────────────
            _standardBlock(
              index: '04',
              title: 'Professional Conduct',
              icon: Icons.handshake_outlined,
              body:
                  'You agree to uphold a high standard of professionalism with clients, horses, '
                  'and other vendors. This includes: punctuality, transparent communication, '
                  'honoring confirmed bookings, and treating all parties with respect. '
                  'Unprofessional conduct may result in account review or removal.',
              checkKey: 'professional',
            ),
            const SizedBox(height: 16),

            // ── Standard 5: Platform Rules ────────────────────────────────
            _standardBlock(
              index: '05',
              title: 'Platform-Only Communication (MVP)',
              icon: Icons.chat_bubble_outline_rounded,
              body:
                  'During this phase of the platform, all client communication and booking '
                  'coordination must occur through Catch Ride\'s in-app messaging system. '
                  'You agree not to solicit off-platform contact during the booking process.',
              checkKey: 'platform',
            ),
            const SizedBox(height: 16),

            // ── Standard 6: Insurance ─────────────────────────────────────
            _standardBlock(
              index: '06',
              title: 'Insurance & Liability',
              icon: Icons.shield_outlined,
              body:
                  'You confirm that the insurance status you select on your profile accurately '
                  'reflects your current coverage. Catch Ride is not responsible for liability '
                  'arising from services provided. You agree to notify the platform if your '
                  'insurance status changes.',
              checkKey: 'insurance',
            ),
            const SizedBox(height: 16),

            // ── Standard 7: Age / Identity ────────────────────────────────
            _standardBlock(
              index: '07',
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
                        () => const ProfileSetupBodyworkScreen(),
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
                'These standards apply specifically to Bodywork Specialist accounts.',
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
    bool highlight = false,
  }) {
    final isChecked = _checks[checkKey] ?? false;
    final accentColor = highlight ? AppColors.softRed : AppColors.deepNavy;

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
              : highlight
              ? AppColors.softRed.withOpacity(0.25)
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
