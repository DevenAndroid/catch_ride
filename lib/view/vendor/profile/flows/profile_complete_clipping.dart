import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_clipping.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_clipping.dart';

class ProfilePageClippingScreen extends StatelessWidget {
  final bool isOwnProfile;

  const ProfilePageClippingScreen({super.key, this.isOwnProfile = true});

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
                  onPressed: () => Get.to(
                    () => const ProfileSetupClippingScreen(),
                  ), // Link directly to edit
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.deepNavy), // Fallback
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
                              () => const BookingsRequestClippingScreen(
                                vendorName: 'Jake Torres',
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

                  // Bio / About
                  _sectionHeader('Professional Overview'),
                  const SizedBox(height: 16),
                  Text(
                    '10 years of experience clipping hunters, jumpers, and dressage horses. '
                    'Specializing in full body clips, trace clips, and hunter clips for pre-show prep. '
                    'Patient with nervous horses and committed to a clean, smooth finish every time.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Attributes Lists
                  _buildAttributeList('Disciplines Worked', [
                    'Hunters',
                    'Jumpers',
                    'Dressage',
                  ]),
                  const SizedBox(height: 20),
                  _buildAttributeList('Typical Horse Level', [
                    'A-Circuit',
                    'Open/Pro',
                    'Green/Young Hoses',
                  ]),
                  const SizedBox(height: 32),

                  // Services & Starting Rates
                  _sectionHeader('Services & Starting Rates'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.mutedGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.mutedGold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.mutedGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rates may vary by location or show week.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Clipping Types
                  Text('Clipping Types', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  _buildServiceRate('Full Body Clip', '150'),
                  _buildServiceRate('Hunter Clip', '120'),
                  _buildServiceRate('Touch Ups', '40'),
                  const SizedBox(height: 16),

                  // Add-Ons
                  Text('Add-Ons', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  _buildServiceRate(
                    'Show Clean Up (bridle path, whiskers)',
                    '30',
                  ),
                  _buildServiceRate('Bath + Clip Prep', '50'),
                  const SizedBox(height: 16),

                  // Custom Services
                  Text(
                    'Custom / Additional Services',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildServiceRate('Night touch-ups', '25'),
                  const SizedBox(height: 32),

                  // Availability Snapshot
                  _sectionHeader('Availability Snapshot'),
                  const SizedBox(height: 12),
                  _buildAvailabilityItem('Wellington', true),
                  _buildAvailabilityItem('Ocala WEC', true),
                  _buildAvailabilityItem('Devon', false),
                  const SizedBox(height: 32),

                  // Travel & Fees
                  _sectionHeader('Travel & Fees'),
                  const SizedBox(height: 12),
                  _buildPolicyRow(
                    Icons.map_outlined,
                    'Travel Preference',
                    'Regional',
                  ),
                  _buildPolicyRow(
                    Icons.local_shipping_outlined,
                    'Travel Fee Type',
                    'Flat fee',
                  ),
                  _buildPolicyRow(
                    Icons.attach_money_rounded,
                    'Travel Fee Details',
                    '\$50 per Barn',
                  ),
                  _buildPolicyRow(
                    Icons.notes_rounded,
                    'Travel Notes',
                    'Will travel up to 2 hours outside Ocala. Minimum 3 horses required for travel over 1 hour.',
                    isMultiLine: true,
                  ),
                  const SizedBox(height: 32),

                  // Policies & Payment
                  _sectionHeader('Policies & Payment'),
                  const SizedBox(height: 12),
                  _buildPolicyRow(
                    Icons.event_busy_outlined,
                    'Cancellation Policy',
                    'Moderate (Free within 48 hours, 50% charge after)',
                  ),
                  _buildPolicyRow(
                    Icons.payment_outlined,
                    'Payment Methods Accepted',
                    'Zelle, Venmo, Cash',
                  ),
                  const SizedBox(height: 32),

                  // Experience Highlights
                  _sectionHeader('Experience Highlights'),
                  const SizedBox(height: 12),
                  _buildHighlightBox(
                    'Worked with Olympic Show Jumpers in 2024',
                  ),
                  _buildHighlightBox('Clipping Manager for top A-Circuit Barn'),
                  _buildHighlightBox(
                    'Rehabilitated clipper-shy horses program',
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

  Widget _buildHighlightBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_border, color: AppColors.mutedGold, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
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
            'JT',
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
                'Jake Torres',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Precision Clip Co.',
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
                    'Ocala, FL',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.work_outline,
                    size: 16,
                    color: AppColors.mutedGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '10 Years Exp',
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

  Widget _buildAvailabilityItem(String showName, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.successGreen.withOpacity(0.05)
            : AppColors.softRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? AppColors.successGreen.withOpacity(0.3)
              : AppColors.softRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.event_available : Icons.event_busy,
            size: 20,
            color: isAvailable ? AppColors.successGreen : AppColors.softRed,
          ),
          const SizedBox(width: 12),
          Text(
            isAvailable
                ? 'Available in $showName'
                : 'Fully booked in $showName',
            style: AppTextStyles.titleMedium.copyWith(
              color: isAvailable ? AppColors.successGreen : AppColors.softRed,
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
          Row(
            children: [
              const Icon(Icons.check, color: AppColors.deepNavy, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            'Starting at \$$price',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
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
