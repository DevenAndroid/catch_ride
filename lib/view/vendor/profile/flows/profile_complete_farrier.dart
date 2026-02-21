import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/farrier_booking_screens.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_farrier.dart';

class ProfilePageFarrierScreen extends StatelessWidget {
  final bool isOwnProfile;

  const ProfilePageFarrierScreen({super.key, this.isOwnProfile = true});

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
                      Get.to(() => const ProfileSetupFarrierScreen()),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.deepNavy),
                  Positioned.fill(
                    child: Container(
                      color: AppColors.deepNavy.withOpacity(0.8),
                    ),
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Get.snackbar('Message', 'Opening chat...'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.deepNavy),
                              foregroundColor: AppColors.deepNavy,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Message'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.to(
                              () => const BookingsRequestFarrierScreen(
                                vendorName: 'Sam Smith',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepNavy,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Request Booking'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Professional Scope
                  _sectionHeader('Professional Scope'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.pets_outlined,
                    'Horse Types & Disciplines',
                    'Hunters, Jumpers, Equitation, Dressage',
                  ),
                  _buildInfoRow(
                    Icons.trending_up,
                    'Typical Level of Horse',
                    'Performance / FEI Level',
                  ),
                  const SizedBox(height: 16),

                  // Professional Overview (Bio)
                  _sectionHeader('Short Bio'),
                  const SizedBox(height: 4),
                  Text(
                    '10+ years as a professional farrier. Specializing in A/AA circuit performance horses, corrective work, and therapeutic shoeing. '
                    'Work closely with vets for lameness and rehabilitation cases. Based in Ocala, FL.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Services & Starting Rates
                  _sectionHeader('Services & Starting Rates'),
                  const SizedBox(height: 4),
                  _buildServiceRate('Trimming', '60'),
                  _buildServiceRate('Front Shoes', '180'),
                  _buildServiceRate('Full Set', '320'),
                  _buildServiceRate('Corrective Work', 'Varies'),
                  _buildServiceRate('Glue-on Shoes', '250'),
                  const SizedBox(height: 12),
                  Text('Add-Ons', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  _buildServiceRate('Aluminum Shoes', '40'),
                  const SizedBox(height: 32),

                  // Service Area & Travel
                  _sectionHeader('Service Area & Travel'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.map_outlined,
                    'Travel Preference',
                    'Regional',
                  ),
                  _buildInfoRow(
                    Icons.location_city_outlined,
                    'Home Base',
                    'Ocala, FL',
                  ),
                  _buildInfoRow(
                    Icons.local_shipping_outlined,
                    'Travel Fee',
                    '\$50 Flat fee (Local area)',
                  ),
                  const SizedBox(height: 16),

                  // Upcoming Availability (Top 3)
                  _sectionHeader('Upcoming Availability'),
                  const SizedBox(height: 4),
                  _buildAvailabilityItem(
                    'Mon, Mar 15 - Fri, Mar 19',
                    'Wellington Equestrian Center',
                  ),
                  _buildAvailabilityItem(
                    'Sat, Mar 20 (Mornings)',
                    'Ocala Showgrounds',
                  ),
                  _buildAvailabilityItem(
                    'Tue, Mar 23 (Full Day)',
                    'Tryon International',
                  ),
                  const SizedBox(height: 32),

                  // Client Intake + Scheduling Preferences
                  _sectionHeader('Client Intake & Scheduling'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.person_add_outlined,
                    'New Client Policy',
                    'Limited availability',
                  ),
                  _buildInfoRow(
                    Icons.format_list_numbered_rtl,
                    'Minimum Horses',
                    '2 per stop',
                  ),
                  _buildInfoRow(
                    Icons.emergency_outlined,
                    'Emergency Support',
                    'Yes - Show emergencies only',
                  ),
                  const SizedBox(height: 32),

                  // Notes for Trainers
                  _sectionHeader('Notes for Trainers'),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.mutedGold.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mutedGold.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Best way to reach me for last-minute scheduling is via Catch Ride inbox. Please ensure horses are caught and ready in a well-lit shoeing area.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Career Highlights
                  _sectionHeader('Experience Highlights'),
                  const SizedBox(height: 12),
                  _buildHighlight(
                    'Farrier for multiple GP winners at WEC Ocala',
                  ),
                  _buildHighlight('AFA Certified Journeyman Farrier'),
                  _buildHighlight('15 years working with top equestrian vets'),
                  const SizedBox(height: 32),

                  // Compliance
                  _sectionHeader('Compliance & Policies'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.event_busy_outlined,
                    'Cancellation Policy',
                    'Moderate (48+ hrs)',
                  ),
                  _buildInfoRow(
                    Icons.payment_outlined,
                    'Payment Methods',
                    'Venmo, Zelle, Cash, Credit Card',
                  ),
                  _buildInfoRow(
                    Icons.verified_user_outlined,
                    'Insurance',
                    'Carries Insurance (Document on file)',
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.grey200,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.grey400,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sam Smith',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.deepNavy,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Smith Farrier Services',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _headerIconRow(
                    Icons.location_on_outlined,
                    'Ocala, FL (Home Base)',
                  ),
                  const SizedBox(height: 4),
                  _headerIconRow(
                    Icons.calendar_today_outlined,
                    '10+ Years Experience',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerIconRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.mutedGold),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.grey500,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.mutedGold,
              borderRadius: BorderRadius.circular(2),
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
          Text(title, style: AppTextStyles.bodyMedium),
          Text(
            price == 'Varies' ? 'Varies' : '\$$price',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.deepNavy.withOpacity(0.7)),
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

  Widget _buildHighlight(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.star, color: AppColors.mutedGold, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildAvailabilityItem(String range, String loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available,
            color: AppColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  range,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  loc,
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
