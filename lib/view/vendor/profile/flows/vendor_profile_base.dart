// vendor_profile_base.dart
// Shared professional profile page used across all 6 vendor service types
// Named ProfilePage[Service] in the Dev Packet

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/review_card.dart';
import 'package:catch_ride/widgets/star_rating.dart';
import 'package:catch_ride/view/vendor/profile/edit_vendor_profile_screen.dart';
import 'package:catch_ride/view/vendor/services/edit_services_rates_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Profile data model  (replace fields with API / user state)
// ─────────────────────────────────────────────────────────────────────────────

class VendorProfileData {
  final String name;
  final String businessName;
  final String initials;
  final String tagline; // e.g. "Professional Groom • Full Service"
  final String bio;
  final List<String> serviceBadges;
  final List<VendorServiceRate> rates;
  final String operatingRegion; // e.g. "Wellington, FL • Mon–Sat"
  final bool isAcceptingBookings;
  final double rating;
  final int reviewCount;
  final int yearsExp;
  final int jobsDone;
  final IconData serviceIcon;

  const VendorProfileData({
    required this.name,
    required this.businessName,
    required this.initials,
    required this.tagline,
    required this.bio,
    required this.serviceBadges,
    required this.rates,
    required this.operatingRegion,
    this.isAcceptingBookings = true,
    required this.rating,
    required this.reviewCount,
    required this.yearsExp,
    required this.jobsDone,
    required this.serviceIcon,
  });
}

class VendorServiceRate {
  final String label;
  final String rate;
  const VendorServiceRate(this.label, this.rate);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Base Widget
// ─────────────────────────────────────────────────────────────────────────────

class VendorProfileBase extends StatelessWidget {
  final VendorProfileData data;

  /// When true the profile is shown as the vendor's *own* profile
  /// (edit buttons visible). False = public view (trainer/BM sees it).
  final bool isOwnProfile;

  const VendorProfileBase({
    super.key,
    required this.data,
    this.isOwnProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'My Profile' : data.name),
        centerTitle: true,
        automaticallyImplyLeading: !isOwnProfile,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => Get.to(() => const EditVendorProfileScreen()),
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
              title: 'About',
              editAction: isOwnProfile
                  ? () => Get.to(() => const EditVendorProfileScreen())
                  : null,
              child: Text(
                data.bio,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                  color: AppColors.grey700,
                ),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Services & Rates ─────────────────────────────────────────
            _buildSection(
              title: 'Services & Rates',
              editAction: isOwnProfile
                  ? () => Get.to(() => const EditServicesRatesScreen())
                  : null,
              child: Column(
                children: data.rates
                    .map((r) => _ServiceRateRow(rate: r))
                    .toList(),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Operating Region ─────────────────────────────────────────
            _buildSection(
              title: 'Operating Region',
              editAction: isOwnProfile
                  ? () => Get.snackbar('Edit', 'Update operating regions')
                  : null,
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
                      data.operatingRegion,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Availability Status Card ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _AvailabilityBanner(
                isAccepting: data.isAcceptingBookings,
                region: data.operatingRegion,
                isOwnProfile: isOwnProfile,
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Contact Preference note (MVP: in-app only) ───────────────
            _buildSection(
              title: 'Contact',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.deepNavy.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'In-app messaging only. Send an inquiry or booking request to start a conversation.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey100),

            // ── Reviews ──────────────────────────────────────────────────
            _buildReviewsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // ── Trainer CTA (only on public view) ───────────────────────────────
      bottomNavigationBar: !isOwnProfile ? _TrainerCTABar(data: data) : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Header
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
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepNavy,
                  border: Border.all(color: AppColors.mutedGold, width: 3),
                ),
                child: Center(
                  child: Text(
                    data.initials,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.mutedGold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              // Service icon badge
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.mutedGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(data.serviceIcon, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name & business
          Text(data.name, style: AppTextStyles.headlineMedium),
          if (data.businessName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              data.businessName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            data.tagline,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Service badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: data.serviceBadges.map((b) => _Badge(label: b)).toList(),
          ),
          const SizedBox(height: 18),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCol(value: data.reviewCount.toString(), label: 'Reviews'),
              _vDivider(),
              _StatCol(value: data.rating.toStringAsFixed(1), label: 'Rating'),
              _vDivider(),
              _StatCol(value: '${data.yearsExp}+', label: 'Yrs Exp'),
              _vDivider(),
              _StatCol(value: '${data.jobsDone}+', label: 'Jobs Done'),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Section Wrapper
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required Widget child,
    VoidCallback? editAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.titleLarge),
              if (editAction != null)
                TextButton.icon(
                  onPressed: editAction,
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.deepNavy,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Reviews
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildReviewsSection() {
    final reviews = [
      {
        'name': 'Sarah Williams',
        'date': 'Feb 15, 2026',
        'rating': 5.0,
        'comment':
            'Fantastic service — professional, punctual and incredible with the horses. Will definitely rebook.',
      },
      {
        'name': 'Emily Johnson',
        'date': 'Feb 10, 2026',
        'rating': 5.0,
        'comment':
            'Absolutely beautiful work for our show at WEF. Exactly what we needed.',
      },
      {
        'name': 'Michael Davis',
        'date': 'Jan 28, 2026',
        'rating': 4.0,
        'comment': 'Good service, on time and professional.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: AppTextStyles.titleLarge),
              Row(
                children: [
                  Text(
                    data.rating.toStringAsFixed(1),
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(width: 4),
                  StarRating(rating: data.rating, size: 18),
                  Text(
                    ' (${data.reviewCount})',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.map(
            (r) => ReviewCard(
              reviewerName: r['name'] as String,
              date: r['date'] as String,
              rating: r['rating'] as double,
              comment: r['comment'] as String,
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'See All ${data.reviewCount} Reviews →',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: AppColors.grey200);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

class _ServiceRateRow extends StatelessWidget {
  final VendorServiceRate rate;
  const _ServiceRateRow({required this.rate});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.mutedGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(rate.label, style: AppTextStyles.bodyLarge),
            ],
          ),
          Text(
            rate.rate,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBanner extends StatelessWidget {
  final bool isAccepting;
  final String region;
  final bool isOwnProfile;

  const _AvailabilityBanner({
    required this.isAccepting,
    required this.region,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAccepting ? AppColors.successGreen : AppColors.softRed;
    final label = isAccepting
        ? 'Currently Accepting Bookings'
        : 'Not Currently Accepting Bookings';
    final icon = isAccepting ? Icons.check_circle_rounded : Icons.block_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  region,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          if (isOwnProfile)
            IconButton(
              onPressed: () => Get.snackbar('Edit', 'Update availability'),
              icon: Icon(Icons.edit_outlined, size: 18, color: color),
              tooltip: 'Edit Availability',
            ),
        ],
      ),
    );
  }
}

/// Bottom action bar shown to trainers/BMs on the public profile view
class _TrainerCTABar extends StatelessWidget {
  final VendorProfileData data;
  const _TrainerCTABar({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.snackbar(
                  'Messages',
                  'Opening conversation with ${data.name}',
                ),
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
                onPressed: () => Get.snackbar(
                  'Request Sent',
                  'Booking request form loading...',
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
