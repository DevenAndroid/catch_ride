
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/review_card.dart';
import 'package:catch_ride/widgets/star_rating.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.deepNavy,
                    child: Text('JS', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.mutedGold)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Smith', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text('Professional Groom • Full Service', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 8),
                      // Badges
                      Row(
                        children: [
                          _buildBadge('Grooming'),
                          const SizedBox(width: 8),
                          _buildBadge('Clipping'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(),

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
                  
                  // Review List (Placeholder)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const ReviewCard(
                        reviewerName: 'Happy Client',
                        date: 'Oct 20, 2023',
                        rating: 5,
                        comment: 'John did an amazing job with the clipping. Very professional.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.mutedGold),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.deepNavy, fontWeight: FontWeight.w600),
      ),
    );
  }
}
