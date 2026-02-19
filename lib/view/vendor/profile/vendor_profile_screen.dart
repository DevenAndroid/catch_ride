import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/review_card.dart';
import 'package:catch_ride/widgets/star_rating.dart';
import 'package:catch_ride/view/vendor/profile/edit_vendor_profile_screen.dart';
import 'package:catch_ride/view/vendor/services/edit_services_rates_screen.dart';
import 'package:catch_ride/view/vendor/availability/vendor_availability_screen.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.to(() => const EditVendorProfileScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepNavy,
                      border: Border.all(color: AppColors.mutedGold, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        'JS',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.mutedGold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('John Smith', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Professional Groom • Full Service',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Service Badges
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildBadge('Grooming'),
                      _buildBadge('Clipping'),
                      _buildBadge('Braiding'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('124', 'Reviews'),
                      Container(width: 1, height: 40, color: AppColors.grey200),
                      _buildStatColumn('4.8', 'Rating'),
                      Container(width: 1, height: 40, color: AppColors.grey200),
                      _buildStatColumn('8+', 'Yrs Exp'),
                      Container(width: 1, height: 40, color: AppColors.grey200),
                      _buildStatColumn('350+', 'Jobs Done'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(thickness: 8, color: AppColors.grey100),

            // About Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('About', style: AppTextStyles.titleLarge),
                      TextButton.icon(
                        onPressed: () =>
                            Get.to(() => const EditVendorProfileScreen()),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Over 8 years of experience grooming for top Grand Prix jumpers and hunters. '
                    'Available for full show days, specialized clipping, and show braiding. '
                    'Based in Wellington, FL with service across South Florida show circuits.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey200),

            // Services & Rates
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Services & Rates', style: AppTextStyles.titleLarge),
                      TextButton.icon(
                        onPressed: () =>
                            Get.to(() => const EditServicesRatesScreen()),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildServiceRateRow('Full Day Grooming', '\$200 / day'),
                  _buildServiceRateRow('Braiding (Mane + Tail)', '\$65'),
                  _buildServiceRateRow('Full Body Clipping', '\$150'),
                  _buildServiceRateRow('Show Prep (Half Day)', '\$120'),
                ],
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey200),

            // Availability Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
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
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currently Accepting Bookings',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Wellington, FL • Mon – Sat',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Get.to(() => const VendorAvailabilityScreen()),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.successGreen,
                      ),
                      tooltip: 'Edit Availability',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.grey200),

            // Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews', style: AppTextStyles.titleLarge),
                      Row(
                        children: [
                          Text('4.8', style: AppTextStyles.titleLarge),
                          const SizedBox(width: 4),
                          const StarRating(rating: 4.8, size: 18),
                          Text(' (124)', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Review List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final reviews = [
                        {
                          'name': 'Sarah Williams',
                          'date': 'Feb 15, 2026',
                          'rating': 5.0,
                          'comment':
                              'John did an amazing job with the clipping. Very professional and great with the horse.',
                        },
                        {
                          'name': 'Emily Johnson',
                          'date': 'Feb 10, 2026',
                          'rating': 5.0,
                          'comment':
                              'Incredible braiding work for our show at WEF. Will definitely book again!',
                        },
                        {
                          'name': 'Michael Davis',
                          'date': 'Jan 28, 2026',
                          'rating': 4.0,
                          'comment':
                              'Good grooming service. On time and professional.',
                        },
                      ];
                      final review = reviews[index];
                      return ReviewCard(
                        reviewerName: review['name'] as String,
                        date: review['date'] as String,
                        rating: review['rating'] as double,
                        comment: review['comment'] as String,
                      );
                    },
                  ),

                  // See All Reviews
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All 124 Reviews →',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withOpacity(0.15),
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

  Widget _buildStatColumn(String value, String label) {
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

  Widget _buildServiceRateRow(String service, String rate) {
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
              Text(service, style: AppTextStyles.bodyLarge),
            ],
          ),
          Text(
            rate,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }
}
