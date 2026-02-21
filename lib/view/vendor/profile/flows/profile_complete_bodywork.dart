// profile_page_bodywork.dart — ProfilePageBodywork

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'package:catch_ride/view/vendor/bookings/flows/booking_request_bodywork.dart';

// Bodywork Profile explicitly disconnected from VendorProfileBase
// to render highly specialized Bodywork fields (Insurance flag, specialized
// modality pricing array, platform disclaimers).
class ProfilePageBodyworkScreen extends StatelessWidget {
  final bool isOwnProfile;
  const ProfilePageBodyworkScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'My Profile' : 'Dr. Lisa Holt'),
        centerTitle: true,
        automaticallyImplyLeading: !isOwnProfile,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => Get.snackbar('Edit', 'Opening edit flow...'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Header ─────────────────────────────────────────────
            _buildHeader(),
            const Divider(thickness: 8, color: AppColors.grey100),

            // ── Bio ─────────────────────────────────────────────────────
            _buildSection(
              title: 'Short Bio',
              child: Text(
                'Certified equine massage therapist and chiropractic practitioner with 9 years of experience. Providing therapeutic massage, chiropractic adjustments, and acupuncture for performance horses. Works closely with veterinarians and trainers to support recovery, maintenance, and peak performance.',
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                  color: AppColors.grey700,
                ),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Experience & Specialties ─────────────────────────────────
            _buildSection(
              title: 'Experience & Specialties',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: 'Hunter/Jumper'),
                  _Badge(label: 'Dressage'),
                  _Badge(label: 'FEI Level'),
                  _Badge(label: 'Green Horses (Horse Level)'),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Services + Modalities ─────────────────────────────────────
            _buildSection(
              title: 'Services + Modalities',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _modalityItem('Sports Massage', 'From \$175', [
                    '30 min',
                    '60 min',
                    '90 min',
                  ], false),
                  _modalityItem(
                    'Chiropractic',
                    'From \$200',
                    ['45 min'],
                    true, // displays disclaimer
                  ),
                  _modalityItem('Acupuncture', 'From \$185', ['60 min'], true),
                  _modalityItem('PEMF', 'From \$100', ['30 min'], false),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Service Areas + Travel ────────────────────────────────────
            _buildSection(
              title: 'Service Areas & Travel',
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.deepNavy,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wellington, FL • Ocala, FL • WEF Circuit',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Notes for Trainers ────────────────────────────────────────
            _buildSection(
              title: 'Notes For Trainers',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.speaker_notes_outlined,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Limit 3 sessions/day. Prefer 48h notice. Show days only.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Compliance & Policies ──────────────────────────────────────
            _buildSection(
              title: 'Compliance & Policies',
              child: Column(
                children: [
                  _policyRow(
                    Icons.verified_user_outlined,
                    'Insurance on file',
                    AppColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  _policyRow(
                    Icons.cancel_outlined,
                    'Cancellation Policy: 24hrs notice required, 50% fee applies.',
                  ),
                  const SizedBox(height: 12),
                  _policyRow(
                    Icons.payments_outlined,
                    'Payment Methods: Platform (Card), Zelle, Venmo',
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Professional Standards Section ─────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.balance_rounded,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Services provided through Catch Ride are supportive wellness services and are not a substitute for veterinary care. Providers operate within applicable legal and professional guidelines.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48), // Padding before bottom CTA or nav
          ],
        ),
      ),
      bottomNavigationBar: !isOwnProfile ? _TrainerCTABar() : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepNavy,
                  border: Border.all(color: AppColors.mutedGold, width: 3),
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/home_banner.png',
                    ), // placeholder photo
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.verified,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Dr. Lisa Holt', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 2),
          Text(
            'Holt Equine Bodywork',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verified Bodywork Provider',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.successGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCol(value: '9+', label: 'Yrs Exp'),
              Container(width: 1, height: 40, color: AppColors.grey200),
              _StatCol(value: '5.0', label: 'Rating (63)'),
              Container(width: 1, height: 40, color: AppColors.grey200),
              _StatCol(value: '280+', label: 'Jobs Done'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _modalityItem(
    String name,
    String basePrice,
    List<String> lengths,
    bool showDisclaimer,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              Text(
                basePrice,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Lengths
          Wrap(
            spacing: 8,
            children: lengths.map((l) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Text(
                  l,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              );
            }).toList(),
          ),
          // Optional disclaimer
          if (showDisclaimer) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.softRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 12,
                    color: AppColors.softRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Where legally permitted and performed in accordance with applicable veterinary referral/oversight requirements.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.softRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _policyRow(IconData icon, String text, [Color? color]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.grey500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color ?? AppColors.grey700,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.mutedGold.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  const _StatCol({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.deepNavy,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }
}

class _TrainerCTABar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Get.snackbar('Messages', 'Opening conversation...'),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.deepNavy),
                  foregroundColor: AppColors.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(
                  () => const BookingRequestBodyworkScreen(
                    providerName: 'Dr. Lisa Holt',
                  ),
                ),
                icon: const Icon(Icons.calendar_today_rounded),
                label: const Text(
                  'Request Booking',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
