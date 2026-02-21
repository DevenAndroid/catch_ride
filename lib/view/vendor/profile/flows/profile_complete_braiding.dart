import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_braiding.dart';

class ProfilePageBraiderScreen extends StatelessWidget {
  final bool isOwnProfile;

  const ProfilePageBraiderScreen({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App Bar / Hero Image ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.deepNavy,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (!isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: () =>
                      Get.snackbar('Share', 'Opening share sheet...'),
                ),
              if (!isOwnProfile)
                IconButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () =>
                      Get.snackbar('Edit', 'Opening Edit Profile...'),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.deepNavy), // Fallback
                  // In a real app, Image.network for cover photo
                  Positioned.fill(
                    child: Container(
                      color: AppColors.deepNavy.withOpacity(0.8),
                    ), // Overlay layer
                  ),
                ],
              ),
            ),
          ),

          // ── Profile Content ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Book Action
                  if (!isOwnProfile) ...[
                    CustomButton(
                      text: 'Request to Book',
                      onPressed: () =>
                          Get.to(() => const BookingsRequestBraidingScreen()),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Snapshot / Quick Facts
                  _sectionHeader('Professional Snapshot'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _factBox('12', 'Years Exp'),
                      const SizedBox(width: 12),
                      _factBox('4.9', 'Rating', isStar: true),
                      const SizedBox(width: 12),
                      _factBox('210', 'Reviews'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bio / About
                  Text(
                    '12 years braiding for top hunter/jumper barns along the A-circuit. '
                    'Offering running braids, button braids, and French braids for any discipline. '
                    'Known for clean, consistent braids that hold all show day.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Attributes Lists (Disciplines, Levels, Regions)
                  _buildAttributeList('Disciplines', [
                    'Hunters',
                    'Jumpers',
                    'Equitation',
                    'Dressage',
                  ]),
                  const SizedBox(height: 20),
                  _buildAttributeList('Horse Levels', [
                    'A-Circuit',
                    'Open/Pro',
                    'Amateur',
                  ]),
                  const SizedBox(height: 20),
                  _buildAttributeList('Operating Regions', [
                    'Florida',
                    'Northeast',
                    'Mid-Atlantic',
                  ]),
                  const SizedBox(height: 32),

                  // Availability Preview (General only)
                  _sectionHeader('Upcoming Availability'),
                  const SizedBox(height: 12),
                  _buildAvailabilityItem('WEF'),
                  _buildAvailabilityItem('Ocala WEC'),
                  _buildAvailabilityItem('Devon'),
                  const SizedBox(height: 32),

                  // Services & Rates
                  _sectionHeader('Services & Rates'),
                  const SizedBox(height: 12),
                  _buildServiceRate('Hunter Mane + Tail', '75'),
                  _buildServiceRate('Hunter Mane Only', '45'),
                  _buildServiceRate('Hunter Tail Only', '35'),
                  const SizedBox(height: 32),

                  // Preferences & Policies
                  _sectionHeader('Preferences & Policies'),
                  const SizedBox(height: 12),
                  _buildPolicyRow(
                    Icons.map_outlined,
                    'Travel Radius',
                    'Nationwide',
                  ),
                  _buildPolicyRow(
                    Icons.event_busy_outlined,
                    'Cancellation',
                    'Flexible (Free within 48 hours)',
                  ),
                  _buildPolicyRow(
                    Icons.payment_outlined,
                    'Accepted Payments',
                    'Zelle, Venmo, Cash',
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.grey200,
          child: Text(
            'MS',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maria Santos',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Santos Braiding Co.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.mutedGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Wellington, FL',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.deepNavy),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.mutedGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _factBox(String top, String bottom, {bool isStar = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            if (isStar) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    top,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 18, color: AppColors.mutedGold),
                ],
              ),
            ] else ...[
              Text(
                top,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              bottom,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((i) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
              ),
              child: Text(
                i,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityItem(String showName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available,
            size: 20,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: 12),
          Text(
            'Available during $showName',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRate(String title, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '\$$price',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.deepNavy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
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
