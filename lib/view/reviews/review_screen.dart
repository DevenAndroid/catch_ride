
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/review_card.dart';
import 'package:catch_ride/widgets/star_rating.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Text('4.8', style: AppTextStyles.headlineLarge.copyWith(fontSize: 48)),
                  const SizedBox(height: 8),
                  const StarRating(rating: 4.8, size: 24, count: 5),
                  const SizedBox(height: 8),
                  Text('Based on 124 reviews', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 24),
                  
                  // Breakdown Bars
                  _buildRatingBar(5, 0.8),
                  _buildRatingBar(4, 0.15),
                  _buildRatingBar(3, 0.03),
                  _buildRatingBar(2, 0.01),
                  _buildRatingBar(1, 0.01),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Filter Tabs (Optional, not specified but good UX)
            
            // Reviews List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const ReviewCard(
                  reviewerName: 'Sarah Jenkins',
                  date: 'Nov 12, 2023',
                  rating: 5,
                  comment: 'Absolutely amazing experience! The horse was exactly as described and the trainer was very professional.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$star ★', style: AppTextStyles.labelLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.grey200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mutedGold),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text('${(percentage * 100).toInt()}%', style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
